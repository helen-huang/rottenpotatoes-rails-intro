class MoviesController < ApplicationController
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
  
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # Renders app/views/movies/show.<extension> by default
  end

  def index 
    # Initial session and parameters.
    # Choosing a sort will be remembered even when clicking out of the link movie list. 
    @sort_by = params[:sort] || session[:sort]
    @ratings = params[:ratings] || session[:ratings]
    
    
    if @ratings.nil?
      ratings = Movie.ratings
    else
       # keys: 'G', 'PG', 'PG-13', 'R'
      ratings = @ratings.keys
     
    end
    
    # Order by ascending 
    if !@sort_by.nil?
      @movies = Movie.order("#{@sort_by} ASC").where(:rating => ratings)
    else
      @movies = Movie.where(:rating => ratings)
    end 
    
    @all_ratings = Movie.ratings.inject(Hash.new) do | all_ratings, rating |
      all_ratings[rating] = @ratings.nil? ? false : @ratings.has_key?(rating)
      all_ratings
    end
    
    # Current session's sort is being stored here. 
    session[:sort] = @sort_by
    session[:ratings] = @ratings
    # Check that the database is not empty
    if params[:sort].nil? && params[:ratings].nil? && (!session[:sort].nil? || !session[:ratings].nil?)
      flash.keep
      redirect_to movies_path(:sort => session[:sort], :ratings => session[:ratings])
    end
    
  end 
  
  def new
    # Default rendering of new template
  end

  def create
    @movie = Movie.create!(movie_params)
      # Tracks particular information of params and sessions
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end
  
  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
end