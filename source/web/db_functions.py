from models import ReservationStatus, db_session, User, Reservation, Room, Profile, Bill, Role
from datetime import datetime


# PROFILES functions
def get_profile_by_email(email):
    return db_session.query(Profile).filter(Profile.email == email).first()


def get_profile_by_id(id):
    return db_session.query(Profile).filter(Profile.id == id).first()


def create_profile(fname, lname, email, passport_id, passport_img=''):
    # old_profile = get_profile_by_email(email)
    # if(old_profile is not None):
    #     print(f"Profile {email} already exists.")
    #     return old_profile
    new_profile = Profile(first_name=fname, last_name=lname,
                          email=email, passport_id=passport_id, passport_img=passport_img)
    db_session.add(new_profile)
    db_session.commit()
    print(f"Profile {email} created.")
    return new_profile


# USERS Functions
def get_user_by_username(username):
    return db_session.query(User).filter(User.username == username).first()


def get_user_by_phone(phone):
    return db_session.query(User).filter(User.phone == phone).first()


def get_user_by_id(id):
    return db_session.query(User).filter(User.id == id).first()


def get_user_by_login_token(login_token):
    return db_session.query(User).filter(User.login_token == login_token).first()


def create_user(username, password, phone, role=Role.USER, profile_id=None):
    if(get_user_by_username(username)):
        resp = {'status': False, 'msg': f'username {username} is already exists.'}
        print(resp)
        return resp
    if(get_user_by_phone(phone)):
        resp = {'status': False, 'msg': f'phone {phone} is already exists.'}
        print(resp)
        return resp
    new_user = User(username=username, password=password,
                    phone=phone, role=role)
    if(profile_id != None):
        new_user.profile_id = profile_id
    db_session.add(new_user)
    db_session.commit()
    print(f"User {username} created.")
    return {'status': True, 'user': new_user}


def login(username, password):
    if(not username or str(username).strip() == ''):
        return False
    user = get_user_by_username(username)
    if(not user):
        return False
    if(user.password != password):
        return False
    return user


def verify_token(token):
    if(not token or str(token).strip() == ''):
        return False
    user = get_user_by_login_token(token)
    if(not user):
        return False
    return user


def update_email(user, new_email):
    user.profile.email = new_email
    db_session.commit()


def update_fname(user, new_fname):
    user.profile.first_name = new_fname
    db_session.commit()


def update_lname(user, new_lname):
    user.profile.last_name = new_lname
    db_session.commit()


def update_passport_id(user, new_passport_id):
    user.profile.passport_id = new_passport_id
    db_session.commit()


def update_passport_img(user, new_passport_img):
    new_passport_img = new_passport_img.replace('\\', '/')
    user.profile.passport_img = new_passport_img
    db_session.commit()


# ROOMS Functions
def get_room_by_number(number):
    return db_session.query(Room).filter(Room.number == number).first()


def get_room_by_id(id):
    return db_session.query(Room).filter(Room.id == id).first()


def create_room(floor, number, rate):
    if(not get_room_by_number(number)):
        new_room = Room(floor=floor, number=number, rate=rate)
        db_session.add(new_room)
        db_session.commit()
        print(f"room {number} created.")
        return new_room
    else:
        print(f"room {number} already exists.")


# RESERVATIONS functions
def get_all_reservations():
    return db_session.query(Reservation).all()


def get_reservations_by_status(status):
    return db_session.query(Reservation).filter(Reservation.status == status).all()


def get_booked_reservations():
    return get_reservations_by_status(ReservationStatus.BOOKED)


def get_pending_reservations():
    return get_reservations_by_status(ReservationStatus.PENDING)


def get_sent_reservations():
    return get_reservations_by_status(ReservationStatus.SENT)


def get_checked_in_reservations():
    return get_reservations_by_status(ReservationStatus.CHECKED_IN)


def get_checked_out_reservations():
    return get_reservations_by_status(ReservationStatus.CHECKED_OUT)


def get_reservation_by_id(id):
    return db_session.query(Reservation).filter(Reservation.id == id).first()


def create_reservation(arrival_date, departure_date, adults, children, room_id, user_id):
    new_reservation = Reservation(arrival_date=arrival_date, departure_date=departure_date,
                                  adults=adults, children=children, room_id=room_id, user_id=user_id)
    new_reservation.set_nights()
    new_reservation.gen_qrcode()
    db_session.add(new_reservation)
    db_session.commit()
    print('New reservation created.')


def update_reservation_status(id, new_status):
    reservation = get_reservation_by_id(id)
    reservation.status = new_status
    db_session.commit()


def to_booked_reservation(id):
    update_reservation_status(id, ReservationStatus.BOOKED)


def to_sent_reservation(id):
    update_reservation_status(id, ReservationStatus.SENT)


def to_pending_reservation(id):
    update_reservation_status(id, ReservationStatus.PENDING)


def to_checked_in_reservation(id):
    update_reservation_status(id, ReservationStatus.CHECKED_IN)


def to_checked_out_reservation(id):
    update_reservation_status(id, ReservationStatus.CHECKED_OUT)


# BILLS Functions
def create_bill(user_id, reservation_id):
    new_bill = Bill(user_id=user_id,
                    reservation_id=reservation_id)
    # calculate balance
    reservation = get_reservation_by_id(reservation_id)
    new_bill.balance = reservation.nights * reservation.get_room_info().rate
    db_session.add(new_bill)
    db_session.commit()


# DEMO DATA
admin = {
    'username': 'admin',
    'password': '123',
    'phone': '+966 000 000 0000',
}
demo_users = [
    {
        'username': 'Abdul',
        'password': '123456',
        'fname': "Abdulmajeed",
        'lname': "Albilal",
        'email': 'Abdul@gmail.com',
        'phone': '+966 000 000 0001',
        'passport_id': 'P-2234',
    },
    {
        'username': 'Ayman',
        'password': '123456',
        'fname': "Ayman",
        'lname': "Alzahrani",
        'email': 'Ayman@gmail.com',
        'phone': '+966 000 000 0002',
        'passport_id': 'P-1735',
    },
    {
        'username': 'Faisal',
        'password': '123456',
        'fname': "Faisal",
        'lname': "Aljulayfi",
        'email': 'Faisal@gmail.com',
        'phone': '+966 000 000 0003',
        'passport_id': 'P-1712',
    },
    {
        'username': 'test',
        'password': '123',
        'fname': "Test",
        'lname': "Testing",
        'email': 'test@gmail.com',
        'phone': '+966 000 000 004',
        'passport_id': 'P-TEST',
    },
]

demo_rooms = [
    # floor, number, rate
    (1, "001", 599),
    (1, "002", 599),
    (2, "011", 750),
    (3, "023", 1000),
]

demo_reservations = [
    {
        'room_id': 1,
        'user_id': 2,
        'arrival_date': "2022-03-15",
        'departure_date': "2022-03-17",
        'adults': 2,
        'children': 3,
    },
    {
        'room_id': 2,
        'user_id': 3,
        'arrival_date': "2022-04-10",
        'departure_date': "2022-04-15",
        'adults': 1,
        'children': 2,
    },
    {
        'room_id': 3,
        'user_id': 4,
        'arrival_date': "2022-05-22",
        'departure_date': "2022-05-23",
        'adults': 2,
        'children': 1,
    },
    {
        'room_id': 4,
        'user_id': 5,
        'arrival_date': "2022-06-15",
        'departure_date': "2022-06-30",
        'adults': 3,
        'children': 1,
    },
]


def to_date(str_date):
    # YYYY-MM-DD
    return datetime.strptime(str_date, '%Y-%m-%d')


if __name__ == "__main__":
    # create admin
    create_user(
        admin['username'],
        admin['password'],
        admin['phone'],
        Role.ADMIN
    )

    # create demo users profile
    for user_dict in demo_users:
        profile = create_profile(
            user_dict['fname'],
            user_dict['lname'],
            user_dict['email'],
            user_dict['passport_id']
        )
        create_user(
            user_dict['username'],
            user_dict['password'],
            user_dict['phone'],
            Role.USER,
            profile_id=profile.id
        )

    # create demo rooms
    for floor, number, rate in demo_rooms:
        create_room(floor, number, rate)

    # create demo reservations
    for r in demo_reservations:
        create_reservation(
            to_date(r['arrival_date']),
            to_date(r['departure_date']),
            r['adults'],
            r['children'],
            r['room_id'],
            r['user_id']
        )

    # update reservation 1 to pending
    # update_reservation_status(1, ReservationStatus.PENDING)
