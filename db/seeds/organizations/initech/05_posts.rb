# frozen_string_literal: true

puts "Creating posts for Initech tenant..."

ApplicationRecord.with_tenant("initech") do
  # Find categories and users within this tenant
  y2k_category = Category.find_by!(name: "Y2K Compliance")
  tps_category = Category.find_by!(name: "TPS Reports")
  equipment_category = Category.find_by!(name: "Office Equipment")
  software_category = Category.find_by!(name: "Software Development")
  workplace_category = Category.find_by!(name: "Workplace Issues")

  bill_user = User.find_by!(email_address: "bill.lumbergh@initech.com")
  peter_user = User.find_by!(email_address: "peter.gibbons@initech.com")
  michael_user = User.find_by!(email_address: "michael.bolton@initech.com")
  samir_user = User.find_by!(email_address: "samir.nagheenanajar@initech.com")
  tom_user = User.find_by!(email_address: "tom.smykowski@initech.com")
  milton_user = User.find_by!(email_address: "milton.waddams@initech.com")
  joanna_user = User.find_by!(email_address: "joanna@initech.com")

  # Disable post broadcasting to make seeding faster
  Post.suppressing_turbo_broadcasts do
    Post.find_or_create_by!(
      category: tps_category,
      author: bill_user,
      title: "New TPS Report Cover Sheet Requirements"
    ) do |post|
      post.body = "Yeah, if you could just go ahead and make sure you put the new cover sheets on all your TPS reports "\
                  "from now on, that'd be great. We're putting new cover sheets on all the TPS reports before they "\
                  "go out now. Did you see the memo about this? I'll make sure you get another copy of that memo."
      post.created_at = 3.days.ago
    end

    Post.find_or_create_by!(
      category: equipment_category,
      author: milton_user,
      title: "Someone took my stapler"
    ) do |post|
      post.body = "Excuse me, I believe you have my stapler. I could set the building on fire. It's a red Swingline "\
                  "stapler. I was told that I could listen to the radio at a reasonable volume from nine to eleven, "\
                  "I told Bill that if Sandra is going to listen to her headphones while she's filing then I should "\
                  "be able to listen to the radio while I'm collating so I don't see why I should have to turn down "\
                  "the radio because I enjoy listening at a reasonable volume from nine to eleven."
      post.created_at = 1.day.ago
    end

    Post.find_or_create_by!(
      category: software_category,
      author: peter_user,
      title: "Motivation issues affecting code quality"
    ) do |post|
      post.body = "The thing is, it's not that I'm lazy, it's that I just don't care. The problem is that I'm not "\
                  "motivated. If I work my ass off and Initech ships a few extra units, I don't see another dime. "\
                  "So where's the motivation? And here's something else - I have eight different bosses right now. "\
                  "Eight! So when I make a mistake, I have eight different people coming by to tell me about it."
      post.created_at = 5.days.ago
    end

    Post.find_or_create_by!(
      category: y2k_category,
      author: samir_user,
      title: "Y2K bug found in financial calculation module"
    ) do |post|
      post.body = "We discovered a Y2K compliance issue in the financial calculation module. The date handling code "\
                  "is using two-digit years which will cause problems when we roll over to 2000. This affects the "\
                  "interest calculation algorithms and could result in significant monetary discrepancies. We need "\
                  "to update all date fields to four-digit years immediately."
      post.created_at = 7.days.ago
    end

    Post.find_or_create_by!(
      category: workplace_category,
      author: tom_user,
      title: "Customer communication improvements needed"
    ) do |post|
      post.body = "Look, I already told you: I deal with the goddamn customers so the engineers don't have to! I have "\
                  "people skills! I am good at dealing with people! Can't you understand that? What the hell is wrong "\
                  "with you people? However, we do need better documentation and clearer processes for handling "\
                  "customer escalations."
      post.created_at = 2.days.ago
    end

    Post.find_or_create_by!(
      category: software_category,
      author: michael_user,
      title: "Name confusion in system user accounts"
    ) do |post|
      post.body = "There's some confusion with my user account in the system. It keeps getting mixed up with that "\
                  "no-talent ass clown Michael Bolton the singer. Can we please update the system to use employee "\
                  "IDs instead of just names? For the record, I'm Michael Bolton the programmer, not the singer. "\
                  "The singer sucks."
      post.created_at = 4.days.ago
    end

    Post.find_or_create_by!(
      category: equipment_category,
      author: peter_user,
      title: "Printer reliability issues - PC Load Letter error"
    ) do |post|
      post.body = "What the hell does 'PC Load Letter' mean? The printer keeps giving this cryptic error message "\
                  "and nobody knows what it means. We waste at least an hour every day trying to figure out what's "\
                  "wrong with this piece of... equipment. Can we either get a printer that works or get better "\
                  "error messages that humans can understand?"
      post.created_at = 6.hours.ago
    end

    Post.find_or_create_by!(
      category: workplace_category,
      author: joanna_user,
      title: "Flair policy needs clarification"
    ) do |post|
      post.body = "The minimum flair requirement needs to be clarified. If you want me to wear 37 pieces of flair "\
                  "like your pretty boy Brian over there, then make 37 the minimum. Don't make 15 the minimum if "\
                  "you really want more. People can get a cheeseburger anywhere, they come here for the atmosphere "\
                  "and the attitude. But the flair policy is confusing and demoralizing."
      post.created_at = 8.hours.ago
    end

    Post.find_or_create_by!(
      category: workplace_category,
      author: milton_user,
      title: "Desk relocation to Storage Room B-4"
    ) do |post|
      post.body = "They moved my desk to Storage Room B-4. There's no window and it's in the basement. I was told "\
                  "I could listen to the radio at a reasonable volume. Also, there are rats down here. I think they "\
                  "forgot about me during the last reorganization. If this continues, I might have to take drastic "\
                  "action. I could set the building on fire."
      post.created_at = 10.days.ago
    end

    Post.find_or_create_by!(
      category: tps_category,
      author: bill_user,
      title: "Weekend TPS report processing initiative"
    ) do |post|
      post.body = "We're gonna need to go ahead and move you downstairs into storage B. We have some new people "\
                  "coming in, and we need all the space we can get. So if you could just go ahead and pack up your "\
                  "stuff and move it down there, that would be terrific, mmm-kay? Oh, and I'm gonna need you to go "\
                  "ahead and come in on Saturday to process those TPS reports. Thanks."
      post.created_at = 20.minutes.ago
    end
  end
end

puts "✅ Seeded posts for Initech tenant"