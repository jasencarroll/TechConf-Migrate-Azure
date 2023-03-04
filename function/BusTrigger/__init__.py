import logging
import azure.functions as func
import psycopg2
import os
from datetime import datetime
from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail

def main(msg: func.ServiceBusMessage):

    notification_id = int(msg.get_body().decode('utf-8'))
    logging.info('Python ServiceBus queue trigger processed message: %s',notification_id)

    conn = psycopg2.connect(dbname="techconfdb", user="sql_admin@postjc998657",
                              password="P@ssword", host= 'postjc998657@postjc998657.postgres.database.azure.com.postgres.database.azure.com')
    c = conn.cursor()
    try:
        # Get notification message and subject from database using the notification_id
        c.execute("SELECT subect, message FROM notification WHERE id={};".format(notification_id))
        # Get attendees email and name
        c.execute("Select email, first_name FROM attendee;")
        # Loop through each attendee and send an email with a personalized subject
        for (email, fist_name) in attendee:
            mail = Mail(
                from_email="jc@jasencarroll.com"
                to_emails= email, 
                subject= subject,
                plain_text_cojntent= "{}, \n {}".format(first_name, body)
            )
            try:
                SENDGRID_API_KEY = os.environ['SENDGRID_API_KEY']
                sg = SendGridAPIClient(SENDGRID_API_KEY)
                response = sg.send(mail)
            except Exception as e:
                logging.error(e)
        # Update the notification table by setting the completed date and updating the status with the total number of attendees notified
        c.execute("UPDATE notification SET status = '{}', completed_date = '{}' WHERE id = {};".format(status, datetime(utcnow(), notification_id)))
        c.commit()
    except (Exception, psycopg2.DatabaseError) as error:
        logging.error(error)
    finally:
        # Close connection
        c.close()
        conn=close()