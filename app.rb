require('sinatra')
require('sinatra/reloader')
require('./lib/project')
require('./lib/volunteer')
require('pry')
require('pg')
also_reload('lib/**/*.rb')
require './config'

DB = PG.connect(DB_PARAMS)

get('/') do
  redirect to('/projects')
end

get('/purge') do
  DB.exec("DELETE FROM projects *;")
  # DB.exec("ALTER SEQUENCE projects_id_sequence RESTART WITH 1;")
  DB.exec("DELETE FROM volunteers *;")
  # DB.exec("ALTER SEQUENCE volunteers_id_sequence RESTART WITH 1;")
  redirect to('/projects')
end

get('/projects') do
  @projects = Project.all()
  erb(:projects)
end

get('/volunteers') do
  @volunteers = Volunteer.all()
  erb(:volunteers)
end

get ('/projects/new') do
  erb(:new_project)
end

get ('/volunteers/new') do
  erb(:new_volunteer)
end

post ('/projects') do
  name = params[:project_name]
  volunteer = params[:volunteer]
  project = Project.new({:title => title, :id => nil})
  project.save()
  if volunteer != ''
    project.add_volunteer(volunteer)
  end
  redirect to('/projects')
end

post ('/volunteers') do
  name = params[:volunteer_name]
  volunteer = Volunteer.new({:name => name, :id => nil})
  volunteer.save()
  redirect to('/volunteers')
end

# post('/projects/search') do
#   name = params[:name]
#   @query = "#{(name != '') ? ('Name: ' + name) : ? (((name != '') ? ', ' : '') ''}"
#   @projects = Project.search({:name => name})
#   erb(:search)
# end

get ('/projects/:id') do
  @project = Project.find(params[:id].to_i())
  erb(:project)
end

get ('/volunteers/:id') do
  @volunteer = Volunteer.find(params[:id].to_i())
  erb(:volunteer)
end

get ('/projects/:id/edit') do
  @project = Project.find(params[:id].to_i())
  erb(:edit_project)
end

get ('/volunteers/:id/edit') do
  @volunteer = Volunteer.find(params[:id].to_i())
  erb(:edit_volunteer)
end

# patch ('/projects/:id') do
#   @project = Project.find(params[:id].to_i())
#   @project.update({:name => params[:name]})
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

patch ('/volunteers/:id') do
  @volunteer = Volunteer.find(params[:id].to_i())
  @volunteer.update({:name => params[:name]})
  new_project = params[:project_name]
  if (new_project != "")
    project = Project.new({
      :id => nil,
      :name => "#{new_project}",
      :genre => "TBD"
    })
    project.save()
    @volunteer.add_project(project.name)
  end
  redirect to("/volunteers/#{params[:id]}")
end

delete ('/projects/:id') do
  @project = Project.find(params[:id].to_i())
  @project.delete()
  redirect to('/projects')
end

delete ('/volunteers/:id') do
  @volunteer = Volunteer.find(params[:id].to_i())
  @volunteer.delete()
  redirect to('/volunteers')
end





patch('/') do
end
delete('/') do
end
