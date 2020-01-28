class Project
  attr_accessor :id
  attr_accessor :title

  def initialize(attributes)
    @title = attributes.fetch(:title)
    @id = attributes.fetch(:id)
  end


  def save
    result = DB.exec("INSERT INTO projects (title) VALUES ('#{@title}') RETURNING id;")
    @id = result.first().fetch("id").to_i
  end

  def update(attributes)
    attributes = attributes.reduce({}) do |acc, (key, val)|
      acc[key.to_sym] = (val == '') ? nil : val
      acc
    end
    @title = attributes.fetch(:title) || @title
    DB.exec("UPDATE projects SET title = '#{@title}' WHERE id = #{@id};")
  end


  # def update(attributes)
  #     @title = (attributes.fetch(:title) && attributes.fetch(:title) != '') ?
  #       attributes.fetch(:title) :
  #       @title
  #     DB.exec("
  #       UPDATE projects SET title = '#{Project.(@title)}' WHERE id = #{@id};")
  #   end
  #
  # def update(title)
  #   @title = title
  #   DB.exec("UPDATE projects SET title = '#{@title}' WHERE id = #{@id};")
  # end


  def ==(project_to_compare)
    self.title() == project_to_compare.title()
  end

  def self.all
    self.get_projects("SELECT * FROM projects;")
  end

  def self.clear
    DB.exec("DELETE FROM projects *;")
  end

  def self.find(id)
    project = DB.exec("SELECT * FROM projects WHERE id = #{id};").first
    title = project.fetch("title")
    id = project.fetch("id").to_i
    Project.new({:title => title, :id => id,})
  end

  def delete
    DB.exec("DELETE FROM projects WHERE id = #{@id};")
    DB.exec("DELETE FROM volunteers WHERE project_id = #{@id};")
  end



  def self.sort
    self.get_projects("SELECT * FROM projects ORDER BY lower(name);")
    # @projects.values.sort {|a, b| a.name.downcase <=> b.name.downcase}
  end

  def self.search(x)
    self.get_projects("SELECT * FROM projects WHERE name = '#{x}'")
    # @projects.values.select { |e| /#{x}/i.match? e.name}
  end

  def volunteers                         #find volunteers by project
    Volunteer.find_by_project(self.id)
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

end
