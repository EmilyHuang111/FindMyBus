import SwiftUI

struct ContentView: View {
    @State private var selectedSchool = "Choose a school"
    let schools = ["Choose a school", "Westglades Middle School", "Coral Springs High School", "Coral Glades High School", "Falcon Cove Middle School", "Cyprus Bay High School", "American Heritage Plantation"]

    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.blue]), startPoint: .top, endPoint: .bottom)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

