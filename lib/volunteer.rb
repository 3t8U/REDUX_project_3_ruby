class Volunteer
  attr_reader :id, :name, :project_id



  def initialize(attributes)
    @name = attributes.fetch(:name)
    @id = attributes.fetch(:id)
    @project_id = attributes.fetch(:project_id)
  end

  def ==(volunteer_to_compare)
    @id == volunteer_to_compare.id && @name == volunteer_to_compare.name

  end

  def self.clean(string)
    (string.include?("'")) ? string.gsub("'", "''") : string
  end

  def save
    result = DB.exec("
      INSERT INTO volunteers (name) VALUES ('#{Volunteer.clean(@name)}') RETURNING id;")
      add_project(@project_id)
    @id = result.first().fetch('id').to_i
  end

  def self.get_volunteers(db_query)
    volunteers_array = []
    db_query_results = DB.exec(db_query)
    db_query_results.each do |volunteer|
      id = volunteer.fetch('id').to_i
      name = volunteer.fetch('name')
      volunteers_array.push(Volunteer.new({ :id => id, :name => name}))
    end
    volunteers_array
  end

  def self.all
    Volunteer.get_volunteers("SELECT * FROM volunteers;")
  end

  def delete
    DB.exec("DELETE FROM volunteers WHERE id = #{@id};")
    DB.exec("DELETE FROM projects_volunteers WHERE volunteer_id = #{@id};")
  end

  def self.find(id)
    Volunteer.get_volunteers("SELECT * FROM volunteers WHERE id = #{id};").first()
  end

  def self.search(name)
    Volunteer.get_volunteers("SELECT * FROM volunteers WHERE name = '#{self.clean(name)}';").first()
  end

  def update(attributes)
    @name = attributes.fetch(:name) || @name
    DB.exec("UPDATE volunteers SET name = '#{Volunteer.clean(@name)}' WHERE id = #{@id};")
  end

  def add_project(project_id)
    # result = Project.get_projects("
    #   SELECT * FROM projects WHERE name = '#{Volunteer.clean(name)}'")
    # if(result.length <1)
    #   project = Project.new({
    #     :id => nil,
    #     :name => "#{name}",
    #     :genre => "TBD"
    #   })
    #   project.save()
    #   result = [project]
    # end
    DB.exec("INSERT INTO projects_volunteers (project_id, volunteer_id) VALUES (#{project_id}, #{@id});")
  end

  def project_id
    results = DB.exec("SELECT * FROM projects_volunteers WHERE volunteer_id = #{@id};")
    id_string = results.map{ |result| result.fetch("project_id")}.join(', ')
    (id_string != '') ?
      Project.get_projects("SELECT * FROM projects WHERE id IN (#{id_string});") :
      nil
  end

end
