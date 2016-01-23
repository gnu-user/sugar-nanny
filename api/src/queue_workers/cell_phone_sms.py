#!/usr/bin/env python2
import nexmo
import pika
import logging
from jinja2 import Template
import json
from utils import from_envvar

LOG = logging.getLogger(__name__)

config = from_envvar('APP_SETTINGS')
QUEUE = config['QUEUE_PREFIX'] + '.phone_confirm'
TEMPLATE = 'templates/cell_phone_sms.jinja2'


def message_callback(ch, method, properties, body):
    client = nexmo.Client(key=config['NEXMO_API_KEY'],
                          secret=config['NEXMO_API_SECRET'])
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
    result = client.send_2fa_message({'to': message['phone_number'],
                                      'pin': message['phone_number_confirm_code']})
    LOG.debug(json.dumps({'success': True,
                          'message': 'Received message.',
                          'body': result}))
    ch.basic_ack(delivery_tag=method.delivery_tag)


if __name__ == '__main__':
    connection = pika.BlockingConnection(pika.ConnectionParameters(
        host='localhost'))
    channel = connection.channel()

    channel.queue_declare(queue=QUEUE, durable=True)

    channel.basic_qos(prefetch_count=1)
    channel.basic_consume(message_callback,
                          queue=QUEUE)

    logging.basicConfig(level=logging.DEBUG)
    LOG.info('Beginning to process phone code SMS requests...')
    channel.start_consuming()
