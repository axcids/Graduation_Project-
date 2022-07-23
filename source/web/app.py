from flask import Flask, redirect, request, render_template, jsonify, session
import db_functions as db
from models import ReservationStatus, Role
import os
from uuid import uuid4

app = Flask('App')
app.secret_key = "session_secret_key"
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}
UPLOAD_FOLDER = os.path.join('static', 'uploads')


# URIs
# admin URIs
ADMIN_LOGIN_URI = '/admin/login'
ADMIN_DASHBOARD_URI = '/admin/dashboard'
SEND_TO_CLIENT_URI = '/admin/send'
APPROVE_CHECK_IN_URI = '/admin/approve_check_in'
# client URIs
CLIENT_SIGNUP_URI = '/client/signup'
CLIENT_SINGIN_URI = '/client/signin'
CLIENT_PROFILE = '/client/profile'
CLIENT_UPDATE_PROFILE_URI = '/client/update'
CLIENT_UPLOAD_IMG_URI = '/client/upload'
CLIENT_MY_RESERVATIONS_URI = '/client/reservations'
CLIENT_CHECK_IN_URI = '/client/check_in'
CLIENT_CHECK_OUT_URI = '/client/check_out'
# shared URIs
LOGOUT_URI = '/logout'


def session_user():
    user_id = session.get('user', None)
    if(user_id):
        user = db.get_user_by_id(user_id)
        return user
    return False


def check_auth(req):
    token = req.args.get('token', None)
    return db.verify_token(token)


def check_ext(fname):
    return fname.split('.')[-1].lower() in ALLOWED_EXTENSIONS


# ADMIN ROUTES
@app.route(ADMIN_LOGIN_URI, methods=['POST', 'GET'])
def admin_login():
    if(session_user()):
        return redirect(ADMIN_DASHBOARD_URI)
    err = None
    username = ''
    if(request.method == 'POST'):
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '').strip()
        user = db.login(username, password)
        if(user):
            session['user'] = user.id
            return redirect(ADMIN_DASHBOARD_URI)
        else:
            err = "Invalid Credentials"
    return render_template("admin/login.html", err=err, username=username)


@app.route(ADMIN_DASHBOARD_URI)
def admin_dashboard():
    if(not session_user()):
        return redirect(ADMIN_LOGIN_URI)
    reservations = db.get_all_reservations()
    r_type = request.args.get('type', 'all')
    if(r_type == 'booked'):
        reservations = db.get_booked_reservations()
    elif(r_type == 'pending'):
        reservations = db.get_pending_reservations()
    elif(r_type == 'sent'):
        reservations = db.get_sent_reservations()
    elif(r_type == 'checked_in'):
        reservations = db.get_checked_in_reservations()
    elif(r_type == 'checked_out'):
        reservations = db.get_checked_out_reservations()
    reservations = [r.as_dict() for r in reservations]
    return render_template('admin/dashboard.html', reservations=reservations, r_type=r_type)


@app.route(SEND_TO_CLIENT_URI, methods=['POST'])
def send_to_client():
    id = request.form.get('id')
    db.to_sent_reservation(id)
    return redirect(ADMIN_DASHBOARD_URI)


@app.route(APPROVE_CHECK_IN_URI, methods=['POST'])
def approve_check_in():
    id = request.form.get('id')
    db.to_checked_in_reservation(id)
    return redirect(ADMIN_DASHBOARD_URI)


# CLIENT ROUTES
@app.route(CLIENT_SIGNUP_URI, methods=['POST'])
def client_signup():
    # getting user info
    # user table
    username = request.json.get('username', '')
    password = request.json.get('password', '')
    phone = request.json.get('phone', '')
    # profile table
    fname = request.json.get('fname', '')
    lname = request.json.get('lname', '')
    email = request.json.get('email', '')
    passport_id = request.json.get('passport_id', '')
    # creating profile
    profile = db.create_profile(fname, lname, email, passport_id)
    resp = db.create_user(
        username,
        password,
        phone,
        Role.USER,
        profile_id=profile.id
    )
    if(resp['status']):
        return jsonify({'status': True})
    else:
        return jsonify(resp)


@app.route(CLIENT_SINGIN_URI, methods=['POST'])
def client_signin():
    username = request.json.get('username', '')
    password = request.json.get('password', '')
    user = db.login(username, password)
    if(user):
        token = user.generate_login_token()
        return jsonify({'status': True, 'token': token})
    else:
        return jsonify({'status': False})


@app.route(CLIENT_PROFILE, methods=['GET'])
def client_profile():
    user = check_auth(request)
    if(not user):
        return jsonify({'status': False})
    return jsonify({'status': True, 'profile': user.as_dict()})


@app.route(CLIENT_UPLOAD_IMG_URI, methods=['POST'])
def upload_passport_img():
    user = check_auth(request)
    if(not user):
        return jsonify({'status': False})
    print(request.files)
    img = request.files.get('img', None)
    if(not img):
        print("oops1")
        return jsonify({'status': False})
    if(not img.filename):
        print("oops2")
        return jsonify({'status': False})
    if(check_ext(img.filename)):
        print("DONEEEEE1")
        filepath = os.path.join(UPLOAD_FOLDER, str(uuid4()) + '.jpg')
        img.save(filepath)
        db.update_passport_img(user, filepath)
        return jsonify({'status': True})


@app.route(CLIENT_UPDATE_PROFILE_URI, methods=['POST'])
def client_update_profile():
    user = check_auth(request)
    if(not user):
        return jsonify({'status': False})
    # getting user info

    # profile table
    fname = request.json.get('fname', '')
    lname = request.json.get('lname', '')
    email = request.json.get('email', '')
    passport_id = request.json.get('passport_id', '')
    # update info
    db.update_email(user, email)
    db.update_fname(user, fname)
    db.update_lname(user, lname)
    db.update_passport_id(user, passport_id)

    return jsonify({'status': True})


@app.route(CLIENT_MY_RESERVATIONS_URI)
def client_reservations():
    user = check_auth(request)
    if(not user):
        return jsonify({'status': False})
    reservations = [r.as_dict() for r in user.reservations if r.status in [
        ReservationStatus.SENT, ReservationStatus.CHECKED_IN, ReservationStatus.PENDING]]
    for r in reservations:
        del r['user_info']
    return jsonify({'status': True, 'reservations': reservations})


@app.route(CLIENT_CHECK_IN_URI, methods=['POST'])
def client_check_in():
    user = check_auth(request)
    if(not user):
        return jsonify({'status': False})
    db.to_pending_reservation(request.json.get('id'))
    return jsonify({'status': True})


@app.route(CLIENT_CHECK_OUT_URI, methods=['POST'])
def client_check_out():
    user = check_auth(request)
    if(not user):
        return jsonify({'status': False})
    reservation_id = request.json.get('id')
    db.to_checked_out_reservation(reservation_id)
    # create bill
    db.create_bill(user.id, reservation_id)
    return jsonify({'status': True})


@app.route(LOGOUT_URI)
def logout():
    session.clear()
    return redirect(ADMIN_LOGIN_URI)


if __name__ == '__main__':
    app.run(host='0.0.0.0', debug=True)
