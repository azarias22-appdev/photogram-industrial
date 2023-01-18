task sample_data: :environment do 
  starting = Time.now
  p "Creating sample data"

  if Rails.env.development?
    FollowRequest.destroy_all
    User.destroy_all
  end

  usernames = Array.new {Faker::Name.first_name}
  usernames << "Alice"
  usernames << "Bob"

  usernames.each do |username|
    User.create(
      email: "#{username}@example.com",
      username: username,
      password: "password",
      private: [true, false].sample,
    )
  end


  users = User.all

  users.each do |first_user|
    users.each do |second_user|
      if rand < 0.75 
        first_user.sent_follow_requests.create(
          recipient: second_user,
          status: FollowRequest.statuses.values.sample
        )
      end

      if rand < 0.75 
        second_user.sent_follow_requests.create(
          recipient: first_user,
          status: FollowRequest.statuses.values.sample
        )
      end
    end
  end


  users.each do |user|
    rand(15).times do
      photo = user.own_photos.create(
        caption: Faker::Quote.jack_handey,
        image: "https://robohash.org/#{rand(9999)}"
      )
  
      user.followers.each do |follower|
        if rand < 0.5
          photo.fans << follower
        end
  
        if rand <0.25
          photo.comments.create(
            body: Faker::Quote.jack_handey,
            author: follower
          )
        end
      end
    end
  end
  
  ending = Time.now
  p "It took #{(ending - starting).to_i} seconds to create sample data"
  p "#{User.count} users have been created."
  p "#{FollowRequest.count} follow requests have been created."
  p "#{Photo.count} photos"
  p "#{Like.count} likes"
  p "#{Comment.count} comments"
end
