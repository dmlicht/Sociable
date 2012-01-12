require 'faker' if Rails.env =~ /development/i
namespace :db do
  desc "fill database for sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
    make_users
    make_posts
    make_pairs
  end

    def make_users
      admin = User.create!( :name => "Admin User",
                  :email => "Admin@email.com",
                  :password => "adminpass",
                  :password_confirmation => "adminpass"
                  )
      admin.toggle!(:admin)
      99.times do |n|
        name = Faker::Name.name
        email = "example-#{n+1}@example.com"
        password = "validpass"
        User.create!( :name => name,
                    :email => email,
                    :password =>password,
                    :password_confirmation => password
                    )
      end
    end

    def make_posts
      User.all(:limit => 6).each do |user|
        50.times do
          user.posts.create!(:content => Faker::Lorem.sentence(5))
        end
      end
    end
    
    def make_pairs
      users = User.all
      user = users.first
      pending_wings = users[3..7]
      requested_wings = users[8..12]
      accepted_wings = users[9..11]
      pending_wings.each do |wing|
        user.request_wing!(wing)
      end
      requested_wings.each do |wing|
        wing.request_wing!(user)
      end
      accepted_wings.each do |wing|
        user.accept_wing!(wing)
      end
    end
end
