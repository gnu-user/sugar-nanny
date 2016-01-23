#!/usr/bin/env python2
import mandrill
import pika
import logging
from jinja2 import Template
import json
from utils import from_envvar

LOG = logging.getLogger(__name__)
config = from_envvar('APP_SETTINGS')
QUEUE = config['QUEUE_PREFIX'] + '.registration_email'
EMAIL_TEMPLATE = 'templates/registration_email.jinja2'


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
    email_message_params = {'subject': 'Email Confirmation',
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
        message.update({'confirm_link':
                        ('http://sesh.io/account/confirm_email/{}'
                         .format(message['email_confirm_uuid']))})
        message.update({'manual_confirm_link':
                        'http://sesh.io/account/confirm_email'})
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
    LOG.info('Beginning to process registration email requests...')
    channel.start_consuming()
