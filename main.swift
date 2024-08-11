import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @State private var selectedSchool = "Choose a school"
    @State private var email = ""
    @State private var password = ""
    @State private var userName = ""
    @State private var errorMessage: String?
    @State private var navigateToBusTableView = false
    @State private var showForgotPassword = false
    @State private var showConfirmationAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    // App Title
                    Text("FindMyBus")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 50)
                    
                    // Illustration (Placeholder)
                    Image(systemName: "bus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.yellow)
                        .padding(.bottom, 50)
                    
                    // Email and Password Login Section
                    VStack(spacing: 10) {
                        HStack {
                            Text("Email Address")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                        
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                            .autocapitalization(.none)
                        
                        HStack {
                            Text("Password")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal, 40)
                        
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                            .autocapitalization(.none)
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.subheadline)
                                .padding(.horizontal, 40)
                        }
                        
                        Button(action: {
                            login()
                        }) {
                            Text("Login")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 40)
                        
                        if showForgotPassword {
                            Button(action: {
                                forgotPassword()
                            }) {
                                Text("Forgot Password?")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // Sign Up Link
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.bottom, 30)
                            
                    }
                    
                    Spacer()
                    
                    // Navigation Link to Bus Table View
                    NavigationLink(destination: BusTableView(schoolName: selectedSchool)
                                    .navigationBarBackButtonHidden(true)
                                    .navigationBarHidden(true),
                                   isActive: $navigateToBusTableView) {
                        EmptyView()
                    }

                    
                }
                .alert(isPresented: $showConfirmationAlert) {
                    Alert(
                        title: Text("Send Password Reset Email"),
                        message: Text("Are you sure you want to send a password reset email to \(email)?"),
                        primaryButton: .destructive(Text("Send")) {
                            sendPasswordResetEmail()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
        }
    }
    
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                // Check if the error is related to incorrect password
                if error.code == AuthErrorCode.wrongPassword.rawValue {
                    errorMessage = "Incorrect password. Please try again."
                    showForgotPassword = true // Show the Forgot Password button
                } else {
                    errorMessage = "Incorrect pasword or email address."
                    showForgotPassword = true
                }
                return
            }
            
            // Check if the user is signed in
            guard let user = result?.user else {
                errorMessage = "User not found."
                showForgotPassword = false // Hide the Forgot Password button
                return
            }
            
            // Fetch user details from Firestore
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                if let error = error {
                    errorMessage = "Failed to fetch user details: \(error.localizedDescription)"
                    showForgotPassword = false // Hide the Forgot Password button
                    return
                }
                
                guard let data = document?.data() else {
                    errorMessage = "User details not found."
                    showForgotPassword = false // Hide the Forgot Password button
                    return
                }
                
                // Retrieve user data from Firestore
                userName = data["name"] as? String ?? "User"
                selectedSchool = data["school"] as? String ?? "Unknown School"
                
                // Navigate to BusTableView
                navigateToBusTableView = true
                errorMessage = nil // Clear error message on successful login
                showForgotPassword = false // Hide the Forgot Password button
            }
        }
    }

    
    private func forgotPassword() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        
        showConfirmationAlert = true
    }
    
    private func sendPasswordResetEmail() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = "Failed to send reset email: \(error.localizedDescription)"
            } else {
                errorMessage = "Password reset email sent successfully."
            }
        }
    }
}

struct GreetingView: View {
    let name: String
    
    var body: some View {
        VStack {
            Text("Hello, \(name)!")
                .font(.largeTitle)
                .padding()
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}




struct AdminLoginView: View {
    @State private var password: String = ""
    @State private var isAuthenticated: Bool = false
    @State private var showErrorAlert: Bool = false
    let schoolName: String
    
    // Dictionary to map school names to their passwords
    private let passwords = [
        "Westglades Middle School": "123",
        "Coral Springs High School": "1234",
        "Coral Glades High School": "12345",
        "Falcon Cove Middle School": "123456",
        "Cyprus Bay High School": "1234567",
        "American Heritage Plantation": "12345678"
    ]
    
    var body: some View {
        ZStack {
            Color(.systemBrown).opacity(0.2).edgesIgnoringSafeArea(.all)
            VStack {
                Text("Admin Login")
                    .font(.largeTitle)
                    .padding()
                
                // Placeholder Image
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding()
                
                // Password Entry
                SecureField("Enter password", text: $password)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                // Login Button
                Button(action: {
                    if let correctPassword = passwords[schoolName], password == correctPassword {
                        withAnimation {
                            isAuthenticated = true
                        }
                    } else {
                        showErrorAlert = true
                    }
                }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal, 40)
                .alert(isPresented: $showErrorAlert) {
                    Alert(
                        title: Text("Login Error"),
                        message: Text("Incorrect password. Please try again."),
                        dismissButton: .default(Text("OK"))
                    )
                }
                
                // Navigation Link to Bus Table View
                NavigationLink(destination: BusTableView(schoolName: schoolName), isActive: $isAuthenticated) {
                    EmptyView()
                }
                
                Spacer()
            }
        }
    }
}



struct SettingsView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var role: String = ""
    @State private var school: String = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?

    var body: some View {
        ZStack {
            // Full background color
            Color(red: 0.9, green: 0.95, blue: 1.0) // Replace with your desired tan color if needed
            
            VStack(alignment: .leading, spacing: 20) {
                        Text("Account Info")
                            .font(.largeTitle)
                            .padding(.bottom, 20)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack(spacing: -15) { // Adjust the spacing here
                                Text("Name:")
                                    .font(.headline)
                                    .frame(width: 70, alignment: .leading) // Adjust width for alignment
                                TextField("Name", text: $name)
                                    .padding()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            
                            HStack(spacing: -15) { // Adjust the spacing here
                                Text("Email:")
                                    .font(.headline)
                                    .frame(width: 70, alignment: .leading) // Adjust width for alignment
                                TextField("Email", text: $email)
                                    .padding()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(true) // Disable editing for email
                            }
                            
                            HStack(spacing: -15) { // Adjust the spacing here
                                Text("Role:")
                                    .font(.headline)
                                    .frame(width: 70, alignment: .leading) // Adjust width for alignment
                                TextField("Role", text: $role)
                                    .padding()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(true) // Disable editing for role
                            }
                            
                            HStack(spacing: -15) { // Adjust the spacing here
                                Text("School:")
                                    .font(.headline)
                                    .frame(width: 70, alignment: .leading) // Adjust width for alignment
                                TextField("School", text: $school)
                                    .padding()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .disabled(true) // Disable editing for school
                            }
                        }
                        
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }
                        
                        if let successMessage = successMessage {
                            Text(successMessage)
                                .foregroundColor(.green)
                                .padding(.top, 10)
                        }
                
                Button(action: updateAccountSettings) {
                    Text("Update Settings")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                .frame(maxWidth: .infinity) // Make the button take up the full width of its container
                .frame(alignment: .center)
            }
            .padding()
            .onAppear(perform: loadUserData)
        }
        .edgesIgnoringSafeArea(.all) // Ensure background covers entire screen
    }
    
    private func loadUserData() {
        let user = Auth.auth().currentUser
        if let user = user {
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                if let error = error {
                    errorMessage = "Failed to fetch user details: \(error.localizedDescription)"
                    return
                }
                if let data = document?.data() {
                    name = data["name"] as? String ?? ""
                    email = data["email"] as? String ?? ""
                    role = data["role"] as? String ?? "N/A"
                    school = data["school"] as? String ?? "N/A"
                }
            }
        }
    }
    
    private func updateAccountSettings() {
        let user = Auth.auth().currentUser
        guard let user = user else { return }

        // Update Firestore with the new name
        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "name": name
        ]) { error in
            if let error = error {
                errorMessage = "Failed to update settings: \(error.localizedDescription)"
            } else {
                successMessage = "Settings updated successfully!"
            }
        }
    }
}




struct BusTableView: View {
    let schoolName: String
    @State private var navigateToSettings = false
    @Environment(\.presentationMode) var presentationMode // Access the presentation mode to pop the view

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBrown).opacity(0.2).edgesIgnoringSafeArea(.all)
                VStack {
                    // Display Selected School Name
                    Text("\(schoolName) Bus Loop")
                        .font(.largeTitle)
                        .padding()
                    
                    HStack {
                        // First Column
                        VStack(spacing: 0) {
                            ForEach(1...12, id: \.self) { busNumber in
                                HStack {
                                    Text("Bus # \(busNumber)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 4)
                                }
                                .background(Color.clear)
                                .border(Color.gray, width: 0.5)
                            }
                        }
                        .frame(maxWidth: 150)
                        
                        // Second Column
                        VStack(spacing: 0) {
                            ForEach(13...24, id: \.self) { busNumber in
                                HStack {
                                    Text("Bus # \(busNumber)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.vertical, 4)
                                }
                                .background(Color.clear)
                                .border(Color.gray, width: 0.5)
                            }
                        }
                        .frame(maxWidth: 150)
                    }
                    .padding(.top, 50)
                    
                    Spacer()
                }
                .padding(.top, 20) // Adjusted padding for the top section
                .navigationTitle("") // Clear the navigation title
                .navigationBarBackButtonHidden(true) // Hide the default back button
                .navigationBarItems(leading:
                    Button(action: {
                        // Handle logout action
                        logout()
                    }) {
                        Text("Logout")
                            .font(.title)
                    },
                    trailing:
                    Button(action: {
                        navigateToSettings = true
                    }) {
                        Image(systemName: "person.fill") // Person icon
                            .font(.title)
                    }
                    .background(
                        NavigationLink(destination: SettingsView(), isActive: $navigateToSettings) {
                            EmptyView()
                        }
                    )
                )
            }
        }
    }

    private func logout() {
        // Perform your logout logic here, for example:
        // Navigate back to ContentView
        presentationMode.wrappedValue.dismiss() // This will dismiss the current view
    }
}



struct SignUpView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var role: String = "Student" // Default role
    @State private var errorMessage: String?
    @State private var isSignUpSuccessful: Bool = false
    @State private var adminPassword: String = ""
    @State private var isAdminPasswordRequired: Bool = false
    @State private var selectedSchool: String = "" // State for selected school
    @State private var showForgotPasswordAlert: Bool = false // State to trigger forgot password alert

    private let roles = ["Student", "Admin"]
    
    // Dictionary for school admin passwords
    private let schoolAdminPasswords: [String: String] = [
        "Coral Springs High School": "admin123CSHS",
        "Coral Glades High School": "admin123CGHS",
        "Falcon Cove Middle School": "admin123FCMS",
        "Cyprus Bay High School": "admin123CBHS",
        "Westglades Middle School": "admin123WGMS",
        "American Heritage Plantation": "admin123AHP"
    ]
    
    private let schools = ["Coral Springs High School", "Coral Glades High School", "Falcon Cove Middle School", "Cyprus Bay High School", "Westglades Middle School", "American Heritage Plantation"].sorted() // List of schools
    
    // Reference to Firestore database
    let db = Firestore.firestore()
    
    private func isPasswordValid(_ password: String) -> Bool {
        // Check if password is at least 8 characters long
        guard password.count >= 8 else { return false }
        
        // Check if password contains at least one uppercase letter
        let uppercaseLetter = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        
        // Check if password contains at least one number
        let number = password.rangeOfCharacter(from: .decimalDigits) != nil
        
        return uppercaseLetter && number
    }
    
    private func signUp() {
        // Basic validation
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !selectedSchool.isEmpty else {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Please make sure your passwords match"
            return
        }
        
        // Validate password criteria
        guard isPasswordValid(password) else {
            errorMessage = "Password must be at least 8 characters long, contain an uppercase letter, and include a number."
            return
        }
        
        // If Admin role is selected, validate the admin password
        if role == "Admin" {
            guard let correctAdminPassword = schoolAdminPasswords[selectedSchool],
                  adminPassword == correctAdminPassword else {
                errorMessage = "Invalid admin password for the selected school"
                return
            }
        }
        
        // Check if email already exists
        Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
            if let error = error {
                errorMessage = "Failed to check email existence: \(error.localizedDescription)"
                return
            }
            
            if let methods = methods, !methods.isEmpty {
                // Email already exists
                errorMessage = "The email address is already in use."
                return
            }
            
            // Proceed to create the user with Firebase Authentication
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    errorMessage = "Failed to sign up: \(error.localizedDescription)"
                    isSignUpSuccessful = false
                    return
                }
                
                // User created successfully, send verification email
                guard let user = result?.user else {
                    errorMessage = "Failed to get user information."
                    isSignUpSuccessful = false
                    return
                }
                
                user.sendEmailVerification { error in
                    if let error = error {
                        errorMessage = "Failed to send verification email: \(error.localizedDescription)"
                        isSignUpSuccessful = false
                        return
                    }
                    
                    // Save additional user data in Firestore
                    let userData: [String: Any] = [
                        "name": name,
                        "email": email,
                        "role": role,
                        "school": selectedSchool
                    ]
                    
                    self.db.collection("users").document(user.uid).setData(userData) { error in
                        if let error = error {
                            errorMessage = "Failed to save user data: \(error.localizedDescription)"
                            isSignUpSuccessful = false
                        } else {
                            isSignUpSuccessful = true
                            errorMessage = nil

                            // Clear fields after successful sign-up
                            name = ""
                            email = ""
                            password = ""
                            confirmPassword = ""
                            adminPassword = ""
                            selectedSchool = "" // Clear selected school
                        }
                    }
                }
            }
        }
    }
    
    private func sendPasswordResetEmail() {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email address"
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = "Failed to send reset email: \(error.localizedDescription)"
                print("Error: \(error.localizedDescription)")
            } else {
                errorMessage = "A password reset email has been sent to \(email)"
                print("Password reset email sent to: \(email)")
                showForgotPasswordAlert = false // Dismiss the alert
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                
                TextField("Name", text: $name)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                TextField("Email", text: $email)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $password)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                
                Picker("Role", selection: $role) {
                    ForEach(roles, id: \.self) { role in
                        Text(role).tag(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle()) // or .menu for a dropdown style
                .onChange(of: role) { newValue in
                    isAdminPasswordRequired = newValue == "Admin"
                }
                
                Picker("School", selection: $selectedSchool) {
                    Text("Select a school").tag("")
                    ForEach(schools, id: \.self) { school in
                        Text(school).tag(school)
                    }
                }
                .padding()
                .pickerStyle(MenuPickerStyle()) // or .wheel for a wheel style

                if isAdminPasswordRequired {
                    SecureField("Admin Password", text: $adminPassword)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                Button(action: signUp) {
                    Text("Sign Up")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                
                if isSignUpSuccessful {
                    Text("Please check your email for verification link to finish sign up!")
                        .foregroundColor(.green)
                        .padding(.top, 10)
                }
                
                if errorMessage == "The email address is already in use." {
                    VStack {
                        Text("Already have an account?")
                            .padding(.top, 20)
                        
                        NavigationLink(destination: ContentView()) {
                            Text("Login with existing account")
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                        }
                        
                        Button(action: {
                            showForgotPasswordAlert = true
                        }) {
                            Text("Forgot Password?")
                                .foregroundColor(.blue)
                                .padding(.top, 5)
                        }
                        .alert(isPresented: $showForgotPasswordAlert) {
                            Alert(
                                title: Text("Forgot Password"),
                                message: Text("Enter your email address to receive a password reset link."),
                                primaryButton: .default(Text("Send"), action: {
                                    sendPasswordResetEmail()
                                }),
                                secondaryButton: .cancel()
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
}


struct BusTableView_Previews: PreviewProvider {
    static var previews: some View {
        // Provide a sample school name for the preview
        BusTableView(schoolName: "Sample School")
    }
}


struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
