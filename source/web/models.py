# https://docs.sqlalchemy.org/en/14/orm/tutorial.html#connecting
# https://docs.sqlalchemy.org/en/14/orm/basic_relationships.html
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, relationship
from sqlalchemy import Column, Integer, String, Enum, ForeignKey, Float, DateTime
from sqlalchemy.ext.hybrid import hybrid_property
from sqlalchemy.sql import func
from sqlalchemy.orm import sessionmaker
from uuid import uuid4
import qrcode


import enum

DB_URI = "sqlite:///database.db"
engine = create_engine(f'{DB_URI}?check_same_thread=False')

# DB_URI = "mysql://root@localhost/db_name"
# engine = create_engine(f'{DB_URI}?check_same_thread=False')


Session = sessionmaker(engine)
db_session = Session()
db_session.autoflush = False


Base = declarative_base()


class Role(enum.Enum):
    ADMIN = 0
    USER = 1


class ReservationStatus(enum.Enum):
    BOOKED = 0
    PENDING = 1
    SENT = 2
    CHECKED_IN = 3
    CHECKED_OUT = 4


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String, unique=True)
    password = Column(String)
    phone = Column(String)
    role = Column(Enum(Role), default=Role.USER)
    login_token = Column(String)
    # relations
    profile_id = Column(Integer, ForeignKey('profiles.id'))
    profile = relationship("Profile", uselist=False)
    reservations = relationship("Reservation")

    def generate_login_token(self):
        self.login_token = str(uuid4()).replace('-', '')
        db_session.commit()
        return self.login_token

    def as_dict(self):
        dict_data = {c.name: getattr(self, c.name)
                     for c in self.__table__.columns if c.name not in ['login_token', 'password']}
        if(self.profile is not None):
            dict_data['profile'] = self.profile.as_dict()
        dict_data['role'] = str(dict_data['role']).split('.')[-1]
        return dict_data


class Profile(Base):
    __tablename__ = "profiles"
    id = Column(Integer, primary_key=True, autoincrement=True)
    first_name = Column(String)
    last_name = Column(String)
    email = Column(String)
    passport_id = Column(String)
    passport_img = Column(String)

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}


class Reservation(Base):
    __tablename__ = "reservations"
    id = Column(Integer, primary_key=True, autoincrement=True)
    arrival_date = Column(DateTime)
    departure_date = Column(DateTime)
    adults = Column(Integer)
    children = Column(Integer)
    qrcode = Column(String)
    qrcode_img = Column(String)
    status = Column(Enum(ReservationStatus), default=ReservationStatus.BOOKED)

    _nights = Column("nights", Integer)

    @hybrid_property
    def nights(self):
        return self._nights

    def set_nights(self):
        self._nights = (self.departure_date - self.arrival_date).days

    # relations
    room_id = Column(Integer, ForeignKey('rooms.id'))
    user_id = Column(Integer, ForeignKey('users.id'))

    def gen_qrcode(self):
        random_id = str(uuid4())
        save_path = 'static/qr/' + random_id + '.jpg'
        self.qrcode = random_id
        self.qrcode_img = save_path
        img = qrcode.make(random_id)
        img.save(save_path)

    def get_user_info(self):
        return db_session.query(User).filter(User.id == self.user_id).first()

    def get_room_info(self):
        return db_session.query(Room).filter(Room.id == self.room_id).first()

    def as_dict(self):
        dict_data = {c.name: getattr(self, c.name)
                     for c in self.__table__.columns}
        dict_data['user_info'] = self.get_user_info().as_dict()
        dict_data['room_info'] = self.get_room_info().as_dict()
        dict_data['status'] = str(dict_data['status']).split('.')[-1]
        return dict_data


class Room(Base):
    __tablename__ = "rooms"
    id = Column(Integer, primary_key=True, autoincrement=True)
    floor = Column(Integer)
    number = Column(String)
    rate = Column(Float)

    def as_dict(self):
        return {c.name: getattr(self, c.name) for c in self.__table__.columns}


class Bill(Base):
    __tablename__ = "bills"
    id = Column(Integer, primary_key=True, autoincrement=True)
    balance = Column(Float)
    create_date = Column(DateTime, default=func.now())
    # relations
    user_id = Column(Integer, ForeignKey('users.id'))
    reservation_id = Column(Integer, ForeignKey('reservations.id'))

    def get_user_info(self):
        return db_session.query(User).filter(User.id == self.user_id).first()

    def get_reservation_info(self):
        return db_session.query(Reservation).filter(Reservation.id == self.reservation_id).first()

    def as_dict(self):
        dict_data = {c.name: getattr(self, c.name)
                     for c in self.__table__.columns}
        dict_data['reservation'] = self.get_reservation_info().as_dict()
        dict_data['user'] = self.get_user_info().as_dict()
        return dict_data


Base.metadata.create_all(engine)
