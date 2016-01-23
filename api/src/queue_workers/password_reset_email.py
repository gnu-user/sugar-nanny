#!/usr/bin/env python2
import mandrill
import pika
import logging
from jinja2 import Template
from utils import from_envvar
import json

LOG = logging.getLogger(__name__)

config = from_envvar('APP_SETTINGS')
QUEUE = config['QUEUE_PREFIX'] + '.password_reset_email'
EMAIL_TEMPLATE = 'templates/password_reset_email.jinja2'


def message_callback(ch, method, properties, body):
    mandrill_client = mandrill.Mandrill(config['MANDRILL_API_KEY'])
    try:
        message = json.loads(body)
        # TODO: JSON schema validation
    except:
        # TODO: DB insert, or something
        LOG.error(json.dumps({'success': False,
                              'error': 'Unable to decode JSON.',
                              'message': body}))
    LOG.debug(json.dumps({'success': True,
                          'message': 'Received message.',
                          'body': body}))
    email_message_params = {'subject': 'Password Reset Request',
                            'from_email': 'do_not_reply@sesh.io',
                            'from_name': 'SESH',
                            'to': [{'email': message['email'],
                                    'name': '{} {}'
                                    .format(message['first_name'],
                                            message['last_name']),
                                    'type': 'to'}],
                            'auto_html': True,
                            'auto_text': True}
    with open(EMAIL_TEMPLATE) as content:
        email_content = Template(content.read())
        message.update({'reset_link':
                        ('http://sesh.io/account/reset_password/{}'
                         .format(message['reset_token']))})
        message.update({'manual_reset_link':
                        'http://sesh.io/account/reset_password'})
        email_content = email_content.render(**message)
    email_message_params.update({'text': email_content})
    result = mandrill_client.messages.send(message=email_message_params,
                                           async=False)
    LOG.debug(json.dumps({'success': True,
                          'message': 'Processed message.',
                          'body': result}))
    ch.basic_ack(delivery_tag=method.delivery_tag)


# TODO: Use Mandrill templates instead of Jinja2
if __name__ == '__main__':
    connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
    channel = connection.channel()

    channel.queue_declare(queue=QUEUE, durable=True)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(message_callback,
                          queue=QUEUE)

    logging.basicConfig(level=logging.DEBUG)
    LOG.info('Beginning to process password reset email requests...')
    channel.start_consuming()
