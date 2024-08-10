import SwiftUI

struct ContentView: View {
    @State private var selectedSchool = "Choose a school"
    @State private var email = ""
    @State private var password = ""
    let schools = ["Choose a school", "Westglades Middle School", "Coral Springs High School", "Coral Glades High School", "Falcon Cove Middle School", "Cyprus Bay High School", "American Heritage Plantation"]

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
                    
                    // School Picker
                    Picker("Select School", selection: $selectedSchool) {
                        ForEach(schools, id: \.self) { school in
                            Text(school)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal, 40)
                    .padding(.bottom, 10)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    
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
                        
                        Button(action: {
                            // Handle login action here
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
                    }
                    .padding(.bottom, 20)
                    
                    // Sign Up Link
                    NavigationLink(destination: SignUpView()) {
                        Text("Don't have an account? Sign Up")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.bottom, 30)
                    }
                    
                    // Admin Login Button
                    NavigationLink(destination: AdminLoginView(schoolName: selectedSchool)) {
                        Text("Admin")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                    
                    // Student Login Button
                    NavigationLink(destination: BusTableView(schoolName: selectedSchool)) {
                        Text("Student")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal, 40)
                    
                    Spacer()
                }
            }
        }
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

struct BusTableView: View {
    let schoolName: String
    
    var body: some View {
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
            }
        }
    }
}


import SwiftUI

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
    
    private let roles = ["Student", "Admin"]
    private let correctAdminPassword = "123" // Set the correct admin password here
    
    private func signUp() {
        // Basic validation
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields correctly"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Please make sure your passwords match"
            return
        }
        
        // If Admin role is selected, validate the admin password
        if role == "Admin" {
            guard adminPassword == correctAdminPassword else {
                errorMessage = "Invalid admin password"
                return
            }
        }
        
        // Perform the sign-up action (e.g., save to database)
        // Here we'll just simulate a successful sign-up
        isSignUpSuccessful = true
        errorMessage = nil
        
        // Clear fields after successful sign-up
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
        adminPassword = ""
    }
    
    var body: some View {
        VStack {
            Text("Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            TextField("Name", text: $name)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Email", text: $email)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Password", text: $password)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            SecureField("Confirm Password", text: $confirmPassword)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("Role", selection: $role) {
                ForEach(roles, id: \.self) { role in
                    Text(role).tag(role)
                }
            }
            .pickerStyle(SegmentedPickerStyle()) // or .menu for a dropdown style
            .onChange(of: role) { newValue in
                isAdminPasswordRequired = newValue == "Admin"
            }
            
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
                Text("Sign Up Successful!")
                    .foregroundColor(.green)
                    .padding(.top, 10)
            }
        }
        .padding()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
