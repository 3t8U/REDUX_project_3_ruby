require('sinatra')
require('sinatra/reloader')
require('./lib/project')
require('./lib/volunteer')
require('pry')
require('pg')
also_reload('lib/**/*.rb')
require './config'

DB = PG.connect(DB_PARAMS)
# DB =PG.connect({:dbname => "volunteer_tracker"})

get('/') do
  redirect to('/projects')
end


get('/projects') do
  @projects = Project.all()
  erb(:projects)
end

get ('/projects/new') do
  erb(:new_project)
end


# get('/volunteers') do
#   @volunteers = Volunteer.all()
#   erb(:volunteers)
# end
#
#
# get ('/volunteers/new') do
#   erb(:new_volunteer)
# end

post ('/projects') do
  title = params[:title]
  project = Project.new({:title => title, :id => nil})
  project.save()
  redirect to('/projects')
  end


# post ('/volunteers') do ##########====,,..,,.,
#   name = params[:volunteer_name]
#   volunteer = Volunteer.new({:name => name, :id => nil})
#   volunteer.save()
#   redirect to('/volunteer')
# end


get ('/projects/:id') do
  @project = Project.find(params[:id].to_i())
  erb(:project)
end


get ('/projects/:id/edit') do
  @project = Project.find(params[:id].to_i())
  erb(:edit_project)
end
# get ('/volunteers/:id') do
#   @volunteer = Volunteer.find(params[:id].to_i())
#   erb(:volunteer)
# end

# get ('/volunteers/:id/edit') do
#   @volunteer = Volunteer.find(params[:id].to_i())
#   erb(:edit_volunteer)
# end



patch('/projects/:id') do
  @project  = Project.find(params[:id].to_i())
  @project.update(params)
  @projects = Project.all
  redirect to('/projects')
end

delete ('/projects/:id') do
  @project = Project.find(params[:id].to_i())
  @project.delete()
  redirect to('/projects')
end

delete ('/projects/:id/volunteers/:volunteer_id') do
  @volunteer = Volunteer.find(params[:volunteer_id].to_i())
  @volunteer.delete()
  @project = Project.find(params[:id].to_i())
  erb(:project)
end

get ('/projects/:id/volunteers/:volunteer_id') do
  @volunteer = Volunteer.find(params[:volunteer_id].to_i())
  erb(:volunteer)
end

post('/projects/:id/volunteers') do
@project = Project.find(params[:id].to_i())
# params[:project_id] = params[:id]
volunteer = Volunteer.new({:name => params[:volunteer_name], :project_id => @project_id, :id => nil })
volunteer.save()
erb(:project)
end

# Edit a volunteer and then route back to the project view.
patch('/projects/:id/volunteers/:volunteer_id') do ######******>
@project = Project.find(params[:id].to_i())
volunteer = Volunteer.find(params[:volunteer_id].to_i())
volunteer.update(params[:name], @project.id)
erb(:project)
end

get('/purge') do
  DB.exec("DELETE FROM projects *;")
  # DB.exec("ALTER SEQUENCE projects_id_sequence RESTART WITH 1;")
  DB.exec("DELETE FROM volunteers *;")
  # DB.exec("ALTER SEQUENCE volunteers_id_sequence RESTART WITH 1;")
  redirect to('/projects')
end

# patch ('/projects/:id') do
#   @project = Project.find(params[:id].to_i())    ##*********
#   @project.update({:title => params[:title]})
#   new_volunteer = params[:volunteer_name]
#   if (new_volunteer != "")
#     volunteer = Volunteer.new({
#       :id => nil,
#       :name => "#{new_volunteer}"
#     })
#     volunteer.save()
#     @project.add_volunteer(volunteer.name)
#   end
#   redirect to("/projects/#{params[:id]}")
# end
