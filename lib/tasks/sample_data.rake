require 'faker' if Rails.env =~ /development/i
namespace :db do
  desc "fill database for sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke
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
    User.all(:limit => 6).each do |user|
      50.times do
        user.posts.create!(:content => Faker::Lorem.sentence(5))
      end
    end
  end
end
