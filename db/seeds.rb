puts "Seeding database..."

# Create Locations
locations = [
  { name: "Office Kitchen", code: "office-kitchen" },
  { name: "Warehouse A", code: "warehouse-a" },
  { name: "Parking Lot", code: "parking-lot" },
  { name: "Main Lobby", code: "main-lobby" },
  { name: "Server Room", code: "server-room" },
  { name: "Loading Dock", code: "loading-dock" },
  { name: "Break Room", code: "break-room" },
  { name: "Stairwell B", code: "stairwell-b" }
]

locations.each do |loc|
  Location.find_or_create_by!(code: loc[:code]) do |l|
    l.name = loc[:name]
  end
end
puts "  Created #{Location.count} locations"

# Create Users (skip confirmation for seeds)
supervisor1 = User.find_or_create_by!(email: "sarah.manager@company.com") do |u|
  u.first_name = "Sarah"
  u.last_name = "Manager"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :supervisor
  u.skip_confirmation!
end

supervisor2 = User.find_or_create_by!(email: "john.lead@company.com") do |u|
  u.first_name = "John"
  u.last_name = "Lead"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :supervisor
  u.skip_confirmation!
end

employee1 = User.find_or_create_by!(email: "alice.worker@company.com") do |u|
  u.first_name = "Alice"
  u.last_name = "Worker"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :employee
  u.skip_confirmation!
end

employee2 = User.find_or_create_by!(email: "bob.tech@company.com") do |u|
  u.first_name = "Bob"
  u.last_name = "Tech"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :employee
  u.skip_confirmation!
end

employee3 = User.find_or_create_by!(email: "carol.ops@company.com") do |u|
  u.first_name = "Carol"
  u.last_name = "Ops"
  u.password = "password123"
  u.password_confirmation = "password123"
  u.role = :employee
  u.skip_confirmation!
end

puts "  Created #{User.count} users"

# Create Reports
reports_data = [
  {
    title: "Slippery floor near kitchen sink",
    description: "The floor near the kitchen sink is consistently wet after lunch hours. Multiple employees have reported near-slip incidents. The drainage seems to be clogged, causing water to pool on the tile floor.",
    location: "Office Kitchen",
    severity: :high,
    reporter: employee1,
    reported_at: 2.days.ago
  },
  {
    title: "Faulty emergency exit light",
    description: "The emergency exit sign above the south door in Warehouse A is flickering and sometimes goes completely dark. This could be a safety issue during power outages.",
    location: "Warehouse A",
    severity: :critical,
    reporter: employee2,
    reported_at: 1.day.ago
  },
  {
    title: "Pothole in parking lot section C",
    description: "There is a growing pothole approximately 8 inches deep near parking space C-15. It's difficult to see at night and could cause ankle injuries for pedestrians or damage to vehicles.",
    location: "Parking Lot",
    severity: :medium,
    reporter: employee3,
    reported_at: 5.days.ago
  },
  {
    title: "Broken handrail on west stairwell",
    description: "The handrail on the second-floor landing of the west stairwell is loose and wobbles when grabbed. It could detach completely, posing a fall risk.",
    location: "Stairwell B",
    severity: :high,
    reporter: employee1,
    reported_at: 3.days.ago
  },
  {
    title: "Exposed wiring in server room",
    description: "During routine inspection, noticed exposed wiring near rack server #7. The cable management tray has come loose, and wires are hanging at head height. Electrical and tripping hazard.",
    location: "Server Room",
    severity: :critical,
    reporter: employee2,
    reported_at: 6.hours.ago
  },
  {
    title: "Obstructed fire extinguisher in lobby",
    description: "A large potted plant has been placed directly in front of the fire extinguisher station in the main lobby. The extinguisher is not easily accessible in case of emergency.",
    location: "Main Lobby",
    severity: :medium,
    reporter: employee3,
    reported_at: 4.days.ago
  },
  {
    title: "Frayed carpet edge causing trips",
    description: "The carpet near the break room entrance has a frayed edge that curls up. Two employees have already tripped on it this week. Needs repair or replacement of the carpet section.",
    location: "Break Room",
    severity: :low,
    reporter: employee1,
    reported_at: 7.days.ago
  },
  {
    title: "Loading dock ramp surface deterioration",
    description: "The anti-slip surface on the loading dock ramp has worn away in several spots. When wet, the ramp becomes extremely slippery. Forklift operators have reported traction issues.",
    location: "Loading Dock",
    severity: :high,
    reporter: employee2,
    reported_at: 10.days.ago
  },
  {
    title: "Malfunctioning automatic door sensor",
    description: "The automatic sliding door at the main entrance occasionally fails to detect people approaching. The door has closed on at least two employees this week.",
    location: "Main Lobby",
    severity: :medium,
    reporter: employee3,
    reported_at: 8.days.ago
  },
  {
    title: "Chemical storage labels fading",
    description: "Several chemical containers in the warehouse storage area have labels that are fading and becoming unreadable. This makes safe handling difficult and could lead to mixing incompatible chemicals.",
    location: "Warehouse A",
    severity: :high,
    reporter: employee1,
    reported_at: 12.days.ago
  }
]

reports = reports_data.map do |data|
  Report.find_or_create_by!(title: data[:title]) do |r|
    r.description = data[:description]
    r.location = data[:location]
    r.severity = data[:severity]
    r.reporter = data[:reporter]
    r.reported_at = data[:reported_at]
  end
end

puts "  Created #{Report.count} reports"

# Advance some reports through workflow
# Report 3 (pothole) - assigned
reports[2].update!(assignee: supervisor1)
reports[2].assign! if reports[2].may_assign?

# Report 6 (obstructed extinguisher) - assigned and in progress
reports[5].update!(assignee: supervisor2)
reports[5].assign! if reports[5].may_assign?
reports[5].start_work! if reports[5].may_start_work?

# Report 7 (frayed carpet) - resolved
reports[6].update!(assignee: supervisor1)
reports[6].assign! if reports[6].may_assign?
reports[6].start_work! if reports[6].may_start_work?
reports[6].resolve! if reports[6].may_resolve?

# Report 9 (automatic door) - resolved and closed
reports[8].update!(assignee: supervisor2)
reports[8].assign! if reports[8].may_assign?
reports[8].start_work! if reports[8].may_start_work?
reports[8].resolve! if reports[8].may_resolve?
reports[8].close! if reports[8].may_close?

# Report 10 (chemical labels) - assigned
reports[9].update!(assignee: supervisor1)
reports[9].assign! if reports[9].may_assign?

puts "  Updated report statuses"

# Add Comments
Comment.find_or_create_by!(body: "I almost slipped there yesterday. This needs urgent attention.", report: reports[0], user: employee3)
Comment.find_or_create_by!(body: "We've placed a wet floor sign as a temporary measure. Maintenance has been contacted.", report: reports[0], user: supervisor1)

Comment.find_or_create_by!(body: "This is critical - the exit sign is required for fire code compliance.", report: reports[1], user: supervisor2)

Comment.find_or_create_by!(body: "I've marked the pothole with a cone. Can we get this filled by end of week?", report: reports[2], user: supervisor1)

Comment.find_or_create_by!(body: "Carpet section has been replaced. Please verify.", report: reports[6], user: supervisor1)
Comment.find_or_create_by!(body: "Confirmed - looks great. Thanks for the quick fix!", report: reports[6], user: employee1)

Comment.find_or_create_by!(body: "Door sensor replaced and calibrated. No more incidents.", report: reports[8], user: supervisor2)

puts "  Created #{Comment.count} comments"

puts "\nSeeding complete!"
puts "\nDemo Login Credentials:"
puts "  Supervisor: sarah.manager@company.com / password123"
puts "  Supervisor: john.lead@company.com / password123"
puts "  Employee:   alice.worker@company.com / password123"
puts "  Employee:   bob.tech@company.com / password123"
puts "  Employee:   carol.ops@company.com / password123"
