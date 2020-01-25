class Project

  attr_reader :id, :title

  def initialize(attributes)
    @title = attributes.fetch(:title)
    @id = attributes.fetch(:id)
  end

  def ==(project_to_compare)
    @id == project_to_compare.id && @title == project_to_compare.title
  end

  def Project.clean(string)
    (string.include?("'")) ? string.gsub("'", "''") : string
  end

  def save
    result = DB.exec("INSERT INTO projects (title) VALUES ('#{Project.clean(@title)}') RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def self.get_projects(db_query)
    projects_array = []
    db_query_results = DB.exec(db_query)
    db_query_results.each do |project|
      id = project.fetch('id').to_i
      title = project.fetch('title')
      projects_array.push(Project.new({ :id => id, :title => title}))
    end
    projects_array
  end

  def self.all
    Project.get_projects("SELECT * FROM projects;")
  end

  def delete
    DB.exec("DELETE FROM projects WHERE id = #{@id};")
    DB.exec("DELETE FROM projects_volunteers WHERE project_id = #{@id};")
  end

  def self.find(id)
    Project.get_projects("SELECT * FROM projects WHERE id = #{id};").first()
  end

  def self.search(search)
    search.fetch(:title) != ''
      Project.get_projects(" SELECT * FROM projects WHERE lower(title) LIKE '%#{self.clean(search.fetch(:title).downcase)}%'")
    end

  def update(attributes)
    @title = (attributes.fetch(:title) && attributes.fetch(:title) != '') ?
      attributes.fetch(:title) :
      @title
    DB.exec("
      UPDATE projects SET title = '#{Project.clean(@title)}'WHERE id = #{@id};")
  end

  def add_volunteer(title)
    result = Volunteer.get_volunteers("
      SELECT * FROM volunteers WHERE title = '#{Project.clean(title)}'")
    if(result.length <1)
      volunteer = Volunteer.new({
        :id => nil,
        :title => "#{title}"
      })
      volunteer.save()
      result = [volunteer]
    end
    DB.exec("INSERT INTO projects_volunteers (volunteer_id, project_id) VALUES (#{result.first().id}#{@id})")
  end

  def volunteers
    results = DB.exec("SELECT * FROM projects_volunteers WHERE project_id = #{@id}")
    id_string = results.map{ |result| result.fetch("volunteer_id")}.join(', ')
    (id_string != '') ?
      Volunteer.get_volunteers("SELECT * FROM volunteers WHERE id IN (#{id_string});") :
      nil
  end

  # def Project.id
  #
  # end

end
