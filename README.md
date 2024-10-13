# Hotel Self Check-in/out App  

With Digital Transformation, we developed an **Online Hotel Check-in/out System** to replace the current manual process, which relies on paper and direct human interaction. The goal of this project is to provide **functional Web and Mobile Applications** that allow users to check in or out of hotel rooms easily with just a click on their phones.  

---

## 📋 Group Details  

- **Project Title:** Hotel Self Check-in/out App  

---

## 🔧 Prerequisites  

### Software Requirements  
- **Android Studio**  
- **Any IDE** for viewing and editing Python code  

### Web Application Requirements  
- **Flask**  
- **Pip**  
- **SQL Alchemy**  

### Mobile Application Requirements  
- **Dart**  
- **Flutter**  

---

## ⚙️ Setup  

### To Run the Web Application:  

1. **Download Python** version 3.8.3.  
2. **Install Python** and add it to the system PATH.  
3. Check the Python version on the command prompt using:  
   ```bash
   python --version
4. Navigate to the SOURCE folder inside PROJECT_CD using the command prompt.
5. Inside the SOURCE folder, enter the web folder.
6. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
7. Initialize the database by running:
   ```bash
   python db_functions.py
8. Start the web server:
   ```bash
   python app.py
9. Copy the IP address displayed in the command prompt when the server starts.

-------------------------------------------------------------------------------------------------------------------------------

### To Run the Mobile Application:  

1. **Download and install Dart** from the official Dart website.  
2. **Download Flutter SDK** from the official Flutter website.  
3. Create a new folder at `C://` and name it `flutter`.  
4. **Unzip** the downloaded Flutter SDK files into the `flutter` folder.  
5. Open the **Start Menu**, type `env`, and **add the Flutter path** (`C://flutter/bin`) to the system PATH.  
6. Open the command prompt and run:  
   ```bash
   flutter doctor --android-licenses
Accept all the licenses.
7. Open Android Studio, go to Settings > SDK Manager.
8. Select SDK Tools and check the box for Android SDK Command-line Tools, then click Apply to install.
9. Restart Android Studio.
10. Create a new Flutter application in Android Studio.
11. Navigate to: PROJECT_CD/SOURCE/FlutterApp 
12. Copy the pubspec.yaml file from this folder.
13. In Android Studio, change the Project View from Android to Project.
14. Paste the copied pubspec.yaml file into the project folder and click Pub Get (top-right corner) to install dependencies.
15. Copy and replace the lib and App folders from FlutterApp into your new Flutter project folders.
16. Open the API Helper file located at: Helpers/lib/API_helper.dart 
17. On line 7, update the IP address to your local IP address (leave the port unchanged).
18. In Android Studio, click Run to launch the mobile application.


   
