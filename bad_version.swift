import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var navigateToBusTableView = false
    @State private var showForgotPassword = false
    @State private var showConfirmationAlert = false
    @State private var userPreferredBusNumber: String = ""
    @State private var userIsLoggedIn = false
    @State private var userName = ""
    @State private var selectedSchool = ""

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
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
                            .padding(.top, geometry.size.height * 0.03) // Reduced from 0.05 to 0.03
                        
                        // Illustration (Placeholder)
                        Image(systemName: "bus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(geometry.size.width * 0.3, 150), height: min(geometry.size.width * 0.3, 150))
                            .foregroundColor(.yellow)
                            .padding(.bottom, geometry.size.height * 0.03) // Reduced from 0.05 to 0.03
                        
                        // Email and Password Login Section
                        VStack(spacing: 15) {
                            HStack {
                                Text("Email Address")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            TextField("Enter your email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 20)
                                .autocapitalization(.none)
                            
                            HStack {
                                Text("Password")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            SecureField("Enter your password", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 20)
                                .autocapitalization(.none)
                            
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                                    .padding(.horizontal, 20)
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
                            .padding(.horizontal, 20)
                            
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        
                        // Sign Up Link
                        NavigationLink(destination: SignUpView()) {
                            Text("Don't have an account? Sign Up")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .padding(.bottom, 30)
                        }
                        
                        Spacer()
                        
                        // Navigation Link to Bus Table View
                        NavigationLink(destination: BusTableView(schoolName: selectedSchool, preferredBusNumber: userPreferredBusNumber)
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
                .onAppear(perform: checkAuthState) // Check authentication state when the view appears
            }
        }
    }
    
    private func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                if error.code == AuthErrorCode.wrongPassword.rawValue {
                    errorMessage = "Incorrect password. Please try again."
                    showForgotPassword = true
                } else {
                    errorMessage = "Incorrect password or email address."
                    showForgotPassword = true
                }
                return
            }
            
            guard let user = result?.user else {
                errorMessage = "User not found."
                showForgotPassword = false
                return
            }
            
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                if let error = error {
                    errorMessage = "Failed to fetch user details: \(error.localizedDescription)"
                    showForgotPassword = false
                    return
                }
                
                guard let data = document?.data() else {
                    errorMessage = "User details not found."
                    showForgotPassword = false
                    return
                }
                
                userName = data["name"] as? String ?? "User"
                selectedSchool = data["school"] as? String ?? "Unknown School"
                userPreferredBusNumber = data["preferredBusNumber"] as? String ?? "Unknown bus"
                print(userPreferredBusNumber)
                
                navigateToBusTableView = true
                errorMessage = nil
                showForgotPassword = false
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
    
    private func checkAuthState() {
        if Auth.auth().currentUser != nil {
            // User is signed in
            if let user = Auth.auth().currentUser {
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).getDocument { document, error in
                    if let data = document?.data() {
                        userName = data["name"] as? String ?? "User"
                        selectedSchool = data["school"] as? String ?? "Unknown School"
                        navigateToBusTableView = true
                    }
                }
            }
        }
    }
}


struct AdminLoginView: View {
    @State private var userPreferredBusNumber: String = ""
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
        "Cypress Bay High School": "1234567",
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
                NavigationLink(destination: BusTableView(schoolName: schoolName,preferredBusNumber: userPreferredBusNumber), isActive: $isAuthenticated) {
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
    @State private var preferredBusNumber: String = "" // New state for preferred bus number
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var logoImageName: String = ""

    var body: some View {
        ZStack {
            // Full background color
            Color(red: 0.9, green: 0.95, blue: 1.0)
                .ignoresSafeArea() // Ensure background covers the full screen
            
            VStack(alignment: .leading, spacing: 20) {
                Text("Account Info")
                    .font(.largeTitle)
                    .padding(.bottom, -10)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                // Display the logo image if logoImageName is set
                if !logoImageName.isEmpty {
                    HStack {
                        Spacer()
                        Image(logoImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                        Spacer()
                    }
                    .padding(.bottom, -10)
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack(spacing: -15) {
                        Text("Name:")
                            .font(.headline)
                            .frame(width: 70, alignment: .leading)
                        TextField("Name", text: $name)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack(spacing: -15) {
                        Text("Email:")
                            .font(.headline)
                            .frame(width: 70, alignment: .leading)
                        TextField("Email", text: $email)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                    }
                    
                    HStack(spacing: -15) {
                        Text("Role:")
                            .font(.headline)
                            .frame(width: 70, alignment: .leading)
                        TextField("Role", text: $role)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                    }
                    
                    HStack(spacing: -15) {
                        Text("School:")
                            .font(.headline)
                            .frame(width: 70, alignment: .leading)
                        TextField("School", text: $school)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disabled(true)
                    }
                    
                    HStack(spacing: -15) {
                        Text("Bus #:")
                            .font(.headline)
                            .frame(width: 70, alignment: .leading)
                        TextField("Bus Number", text: $preferredBusNumber) // Editable field for preferred bus number
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
                
                if let successMessage = successMessage {
                    HStack {
                        Spacer()
                        Text(successMessage)
                            .foregroundColor(.green)
                            .padding(.top, -10)
                        Spacer()
                    }
                }
                
                Button(action: updateAccountSettings) {
                    Text("Update Settings")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, -15)
                .frame(maxWidth: .infinity)
                .frame(alignment: .center)
                Spacer()
                Spacer()
            }
            .padding()
            .onAppear(perform: loadUserData)
        }
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
                    preferredBusNumber = data["preferredBusNumber"] as? String ?? ""
                    
                    switch school {
                    case "Westglades Middle School":
                        logoImageName = "westglades_logo"
                    case "Coral Springs High School":
                        logoImageName = "coral_springs_logo"
                    case "Coral Glades High School":
                        logoImageName = "coral_glades_logo"
                    case "Falcon Cove Middle School":
                        logoImageName = "falcon_cove_logo"
                    case "Cypress Bay High School":
                        logoImageName = "cypress_bay_logo"
                    case "American Heritage Plantation":
                        logoImageName = "american_heritage_logo"
                    default:
                        logoImageName = ""
                    }
                }
            }
        }
    }
    
    private func updateAccountSettings() {
        let user = Auth.auth().currentUser
        guard let user = user else { return }

        let db = Firestore.firestore()
        db.collection("users").document(user.uid).updateData([
            "name": name,
            "preferredBusNumber": preferredBusNumber // Update the preferred bus number
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
    let preferredBusNumber: String // New property
    
    @State private var navigateToSettings = false
    @State private var navigateToMoreBusInfo = false
    @Environment(\.presentationMode) var presentationMode
    
    @State private var userRole: String = "student"
    @State private var userEmail: String = ""
    
    
    
    
    let departureTimes: [String: String] = [
        "Coral Springs High School": "2:50 PM",
        "Coral Glades High School": "2:50 PM",
        "Falcon Cove Middle School": "2:50 PM",
        "Cyprus Bay High School": "2:50 AM",
        "American Heritage Plantation": "4:00 PM",
        "Westglades Middle School": "2:50 PM",
    ]
    
    @State private var textFieldValues: [[String]] = Array(repeating: Array(repeating: "", count: 4), count: 12)
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBrown).opacity(0.2).edgesIgnoringSafeArea(.all)
                VStack {
                    VStack(alignment: .center) {
                        Text("\(schoolName) Bus Loop")
                            .font(.system(size: 20))
                            .bold()
                            .padding(.bottom, -11)
                        
                        if let departureTime = departureTimes[schoolName] {
                            Text("Bus departs at \(departureTime)")
                                .font(.system(size: 20))
                                .padding(.bottom, 20)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                                .padding(.bottom, -15)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Image("Untitled design")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 120)
                        .padding(.bottom, -15)
                    
                    VStack(spacing: 0) {
                        ForEach(0..<12, id: \.self) { rowIndex in
                            HStack(spacing: 0) {
                                Text("\(rowIndex + 1).")
                                    .font(.system(size: 11))
                                    .frame(width: 20, height: 18, alignment: .leading)
                                    .padding(2)
                                    .border(Color.gray, width: 0.5)
                                
                                TextField("Bus #", text: $textFieldValues[rowIndex][0])
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 12))
                                    .frame(width: 145, height: 18)
                                    .padding(2)
                                    .background(textFieldValues[rowIndex][0] == preferredBusNumber ? Color.yellow : Color.clear)
                                    .border(Color.gray, width: 0.5)
                                    .disabled(userRole != "Admin")
                                
                                Text("\(rowIndex + 12 + 1).")
                                    .font(.system(size: 12))
                                    .frame(width: 20, height: 18, alignment: .leading)
                                    .padding(2)
                                    .border(Color.gray, width: 0.5)
                                
                                TextField("Bus #", text: $textFieldValues[rowIndex][1])
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 11))
                                    .frame(width: 145, height: 18)
                                    .padding(2)
                                    .background(textFieldValues[rowIndex][1] == preferredBusNumber ? Color.yellow : Color.clear)
                                    .border(Color.gray, width: 0.5)
                                    .disabled(userRole != "Admin")
                            }
                        }
                    }
                    .border(Color.black, width: 1)
                    .padding(5)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    if showSuccessMessage {
                        Text("Bus info saved successfully!")
                            .foregroundColor(.green)
                            .padding(.top, -20)
                            .padding(.bottom, -20)
                            .transition(.opacity)
                            .animation(.easeInOut, value: showSuccessMessage)
                    }
                    
                    Spacer()
                    
                    if userRole == "Admin" {
                        Button(action: {
                            saveBusInfoToFirebase()
                        }) {
                            Text("Save")
                                .font(.title2)
                                .padding(10)
                                .frame(width: 200, height: 40)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 2)
                    }
                    
                    Button(action: {
                        navigateToMoreBusInfo = true
                    }) {
                        Text("More Bus Info")
                            .font(.title2)
                            .padding(10)
                            .frame(width: 200, height: 40)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .background(
                        NavigationLink(destination: MoreBusInfoView(schoolName: schoolName), isActive: $navigateToMoreBusInfo) {
                            EmptyView()
                        }
                    )
                    
                    Spacer()
                }
                .padding(.top, 20)
                .navigationTitle("")
                .navigationBarBackButtonHidden(true)
                .navigationBarItems(leading:
                    Button(action: {
                        logout()
                    }) {
                        HStack {
                            Image(systemName: "door.left.hand.open")
                                .font(.body)
                                .foregroundColor(.red)
                            Text("Logout")
                                .font(.body)
                                .foregroundColor(.red)
                        }
                    },
                    trailing:
                    Button(action: {
                        navigateToSettings = true
                    }) {
                        Image(systemName: "person.fill")
                            .font(.title)
                    }
                    .background(
                        NavigationLink(destination: SettingsView(), isActive: $navigateToSettings) {
                            EmptyView()
                        }
                    )
                )

                VStack {
                    Spacer()
                    HStack {
                        Button(action: {
                            refreshData()
                        
                        }) {
                            Image("refresh")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                        .padding(.leading, 40)
                        Spacer()
                    }
                    .padding(.bottom, 90)
                }
            }
        }
        .refreshable {
            fetchBusInfo()
        }
        .onAppear {
            fetchUserRole()
            //fetchUserBusNumber()
            print(preferredBusNumber)
            fetchBusInfo()
        }
    }
    
    func refreshData() {
        fetchBusInfo()
    }
    
    
        
    

    
    
    private func saveBusInfoToFirebase() {
        let db = Firestore.firestore()
        let busInfo = textFieldValues.flatMap { $0 } // Flatten the array
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Format as "YYYY-MM-DD"
        let formattedDate = dateFormatter.string(from: currentDate)
        let email = userEmail // User's email
        
        // Document path: "bus_info/{formattedDate}/{schoolName}/{email}"
        let documentPath = "bus_info/\(formattedDate)/\(schoolName)/\(schoolName)"
        
        // Document data
        let documentData: [String: Any] = [
            "busNumbers": busInfo,
            "timestamp": Timestamp(date: currentDate),
            "email": email,
            "school": schoolName
        ]
        
        db.document(documentPath).setData(documentData) { error in
            if let error = error {
                print("Error saving bus info: \(error.localizedDescription)")
            } else {
                print("Bus info saved successfully!")
                showSuccessMessage = true
                
                // Automatically hide the success message after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showSuccessMessage = false
                    }
                }
            }
        }
    }


    private func fetchBusInfo() {
        let db = Firestore.firestore()
        
        // Get the current date and format it
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Format as "YYYY-MM-DD"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        // Document path: "bus_info/{formattedDate}/{schoolName}"
        let docRef = db.collection("bus_info").document("\(formattedDate)").collection(schoolName).document(schoolName)

        docRef.getDocument { document, error in
            if let document = document, document.exists {
                if let data = document.data(), let busNumbers = data["busNumbers"] as? [String] {
                    // Convert busNumbers to 2D array for text fields
                    let rows = 12
                    let columns = 2
                    var newTextFieldValues = Array(repeating: Array(repeating: "", count: columns), count: rows)
                    
                    for (index, number) in busNumbers.enumerated() {
                        let row = index / columns
                        let column = index % columns
                        if row < rows {
                            newTextFieldValues[row][column] = number
                        }
                    }
                    
                    DispatchQueue.main.async {
                        textFieldValues = newTextFieldValues
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }


    private func fetchUserRole() {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("No user is logged in")
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(userID).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                userRole = data?["role"] as? String ?? "student"
                userEmail = data?["email"] as? String ?? ""
            } else {
                print("User document does not exist")
            }
        }
    }

    private func logout() {
        do {
            try Auth.auth().signOut()
            // Navigate back to ContentView
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
}





struct MoreBusInfoView: View {
    let schoolName: String
    @State private var busInfo: String = "" // State variable to hold the text in the text box
    @State private var isAdmin: Bool = false // State to track if the user is an admin
    @State private var successMessage: String? = nil // State variable for the success message
    @State private var userEmail: String? = nil // State to hold the user's email
    @State private var messages: [BusMessage] = [] // State to hold all messages for the day

    // Firebase Auth user
    @StateObject private var userAuth = UserAuth()

    var body: some View {
        ZStack {
            // Set the background color to cover the whole screen
            Color(.systemBrown).opacity(0.2)
                .edgesIgnoringSafeArea(.all) // Extend the background color to the edges

            VStack {
                Text("\(schoolName) Bus Messages")
                    .font(.system(size: 20))
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                // Conditionally display the text box based on user role
                if isAdmin {
                    TextEditor(text: $busInfo)
                        .frame(width: 300, height: 200) // Adjust width and height as needed
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    Spacer()
                    // Save Button
                    Button(action: saveBusInfo) {
                        Text("Save")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                // Success Message
                if let message = successMessage {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                }
                
                // Display Messages
                List(messages) { message in
                    VStack(alignment: .leading) {
                        Text(message.info)
                            .font(.body)
                        Text("Posted by: \(message.updatedBy)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Timestamp: \(message.timestamp.dateValue(), formatter: dateFormatter)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("More Bus Info")
        .onAppear {
            fetchUserRole() // Fetch the user role when the view appears
            fetchUserEmail() // Fetch the user email when the view appears
            fetchMessages() // Fetch existing messages when the view appears
        }
    }
    
    // Fetch the user role from Firebase and set the isAdmin state
    private func fetchUserRole() {
        guard let userId = userAuth.currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let role = data?["role"] as? String ?? ""
                isAdmin = (role == "Admin")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    // Fetch the user email from Firebase Auth
    private func fetchUserEmail() {
        userEmail = userAuth.currentUser?.email
    }
    
    // Save the bus info to Firestore
    private func saveBusInfo() {
        guard let userId = userAuth.currentUser?.uid else {
            print("User not authenticated")
            return
        }
        
        let db = Firestore.firestore()
        let now = Timestamp()
        db.collection("bus_messages").document(schoolName).collection("messages").addDocument(data: [
            "info": busInfo,
            "updatedBy": userEmail ?? "Unknown",
            "school": schoolName,
            "timestamp": now
        ]) { error in
            if let error = error {
                print("Error writing document: \(error)")
                successMessage = "Failed to save. Please try again." // Set error message if save fails
            } else {
                successMessage = "Successfully saved!" // Set success message if save is successful
                fetchMessages() // Refresh the list of messages after saving
            }
        }
    }
    
    // Fetch messages for the current day
    private func fetchMessages() {
        let db = Firestore.firestore()
        let now = Timestamp()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: now.dateValue())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("bus_messages").document(schoolName).collection("messages")
            .whereField("timestamp", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("timestamp", isLessThan: Timestamp(date: endOfDay))
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                } else {
                    messages = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: BusMessage.self)
                    } ?? []
                }
            }
    }
}


// Data model for messages
struct BusMessage: Identifiable, Codable {
    @DocumentID var id: String?
    var info: String
    var updatedBy: String
    var school: String
    var timestamp: Timestamp
}

// A simple ObservableObject class to manage user authentication
class UserAuth: ObservableObject {
    @Published var currentUser: User? = Auth.auth().currentUser
}

// DateFormatter for displaying timestamp
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()



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
    @State private var preferredBusNumber: String = "" // State for preferred bus number

    private let roles = ["Student", "Admin"]
    
    // Dictionary for school admin passwords
    private let schoolAdminPasswords: [String: String] = [
        "Coral Springs High School": "admin123CSHS",
        "Coral Glades High School": "admin123CGHS",
        "Falcon Cove Middle School": "admin123FCMS",
        "Cypress Bay High School": "admin123CBHS",
        "Westglades Middle School": "admin123WGMS",
        "American Heritage Plantation": "admin123AHP"
    ]
    
    private let schools = ["Coral Springs High School", "Coral Glades High School", "Falcon Cove Middle School", "Cypress Bay High School", "Westglades Middle School", "American Heritage Plantation"].sorted() // List of schools
    
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
                
                // User created successfully
                guard let user = result?.user else {
                    errorMessage = "Failed to get user information."
                    isSignUpSuccessful = false
                    return
                }
                
                // Send email verification
                user.sendEmailVerification { error in
                    if let error = error {
                        errorMessage = "Failed to send verification email: \(error.localizedDescription)"
                        isSignUpSuccessful = false
                        return
                    }
                    
                    // Save additional user data in Firestore
                    var userData: [String: Any] = [
                        "name": name,
                        "email": email,
                        "role": role,
                        "school": selectedSchool
                    ]
                    
                    // Add preferred bus number if the role is Student
                    if role == "Student" {
                        userData["preferredBusNumber"] = preferredBusNumber
                    }
                    
                    self.db.collection("users").document(user.uid).setData(userData) { error in
                        if let error = error {
                            errorMessage = "Failed to save user data: \(error.localizedDescription)"
                            isSignUpSuccessful = false
                        } else {
                            isSignUpSuccessful = true
        
                            // Clear fields after successful sign-up
                            name = ""
                            email = ""
                            password = ""
                            confirmPassword = ""
                            adminPassword = ""
                            selectedSchool = "" // Clear selected school
                            preferredBusNumber = "" // Clear preferred bus number
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
            VStack(spacing: 12) { // Increased spacing between fields
                Text("Sign Up")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, -30) // Adjust top padding to shift up
                    .padding(.bottom, 12) // Increased bottom padding

                TextField("Name", text: $name)
                    .padding(.vertical, 12) // Increased vertical padding
                    .padding(.horizontal, 12) // Horizontal padding remains
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                TextField("Email", text: $email)
                    .padding(.vertical, 12) // Increased vertical padding
                    .padding(.horizontal, 12) // Horizontal padding remains
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding(.vertical, 12) // Increased vertical padding
                    .padding(.horizontal, 12) // Horizontal padding remains
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding(.vertical, 12) // Increased vertical padding
                    .padding(.horizontal, 12) // Horizontal padding remains
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                Picker("Role", selection: $role) {
                    ForEach(roles, id: \.self) { role in
                        Text(role).tag(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: role) { newValue in
                    isAdminPasswordRequired = newValue == "Admin"
                }

                Picker("School", selection: $selectedSchool) {
                    Text("Select a school").tag("")
                    ForEach(schools, id: \.self) { school in
                        Text(school).tag(school)
                    }
                }
                .pickerStyle(MenuPickerStyle()) // or .wheel for a wheel style

                if isAdminPasswordRequired {
                    SecureField("Admin Password", text: $adminPassword)
                        .padding(.vertical, 12) // Increased vertical padding
                        .padding(.horizontal, 12) // Horizontal padding remains
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                if role == "Student" {
                    TextField("Preferred Bus Number", text: $preferredBusNumber)
                        .padding(.vertical, 12) // Increased vertical padding
                        .padding(.horizontal, 12) // Horizontal padding remains
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 8) // Increased top padding
                }

                Button(action: signUp) {
                    Text("Sign Up")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 20) // Increased top padding

                if isSignUpSuccessful {
                    Text("Check your email for verification link to finish sign up!")
                        .foregroundColor(.green)
                        .padding(.top, 12) // Increased top padding
                }

                if errorMessage == "The email address is already in use." {
                    VStack {
                        Text("Already have an account?")
                            .padding(.top, 24) // Increased top padding

                        NavigationLink(destination: ContentView()) {
                            Text("Login with existing account")
                                .foregroundColor(.blue)
                                .padding(.top, 8) // Increased top padding
                        }

                        Button(action: {
                            showForgotPasswordAlert = true
                        }) {
                            Text("Forgot Password?")
                                .foregroundColor(.blue)
                                .padding(.top, 8) // Increased top padding
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
            .padding(.horizontal, 16)
            .navigationBarHidden(true)
        }
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
