from app import pika_pool
import json
import pika


def request_phone_confirm(prefix, account):
    queue_name = prefix + '.phone_confirm'
    with pika_pool.acquire() as conn:
        conn.channel.queue_declare(queue_name, durable=True)
        conn.channel.basic_publish(
            exchange='',
            routing_key=queue_name,
            body=json.dumps(account),
            # persistent
            properties=pika.BasicProperties(delivery_mode=2))
