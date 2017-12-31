class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :feed, :following, :followers]

  def following
    @follow = User.find_by_sql(['SELECT "users".* FROM "users" INNER JOIN "relationships" ON "users"."id" = "relationships"."followed_id" WHERE "relationships"."follower_id" = ?', @user.id])
  end

  def search
    unless params[:search].empty?
      @users = User.search(params[:search])
    else
      @users = User.find_by_sql('SELECT "users".* FROM "users"')
    end
  end

  def followers
    @follow = User.find_by_sql(['SELECT "users".* FROM "users" INNER JOIN "relationships" ON "users"."id" = "relationships"."follower_id" WHERE "relationships"."followed_id" = ?', @user.id])
  end

  def follow
    u = User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1',params[:user_id]])[0]
    current_user.follow(u)
    redirect_to :back
  end

  def unfollow
    u = User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1',params[:user_id]])[0]
    current_user.unfollow(u)
    redirect_to :back
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if @user != current_user
      redirect_to :action => 'feed', :id => @user.id
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    valid = @user.valid?

    if valid
      sql_parts = ["INSERT INTO users (username, email, age, firstname, lastname, phone, password_digest, created_at, updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                  @user.username, @user.email, @user.age, @user.firstname, @user.lastname, @user.phone, @user.password_digest, Time.now, Time.now]
      sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
      id = ApplicationRecord.connection.insert(sql)
    end

    respond_to do |format|
      if valid && id
        format.html { redirect_to '/signin', notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update

    if @user.username == user_params[:username] && @user.email == user_params[:email]
      if user_params[:password].blank?
        sql_parts = ["UPDATE users SET phone = ?, firstname = ?, lastname = ?, age = ?, updated_at = ?",
                      user_params[:phone], user_params[:firstname], user_params[:lastname], user_params[:age], Time.now]
      else
        sql_parts = ["UPDATE users SET username = ?, email = ?, phone = ?, firstname = ?, lastname = ?, age = ?, updated_at = ?, password_digest = ?",
                    user_params[:username], user_params[:email], user_params[:phone], user_params[:firstname], user_params[:lastname], user_params[:age], Time.now, User.digest(user_params[:password])]
      end
    end

    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
     ApplicationRecord.connection.execute(sql)

    #respond_to do |format|
    #  if @user.update(user_params)
    #    format.html { redirect_to @user, notice: 'User was successfully updated.' }
    #    format.json { render :show, status: :ok, location: @user }
    #  else
    #    format.html { render :edit }
    #    format.json { render json: @user.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
  end

  def feed
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      # @user = User.find(params[:id])
      @user = User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1', params[:id]])[0]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:username, :email, :password, :salt, :phone, :firstname, :lastname, :sex, :age)
    end
end
