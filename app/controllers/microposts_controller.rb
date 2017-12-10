class MicropostsController < ApplicationController
  before_action :set_micropost, only: [:show, :update]
  before_action :set_edit, only: [:destroy, :edit]

  # GET /microposts
  # GET /microposts.json
  def index
    # @microposts = Micropost.order('created_at DESC')
    # @test = tmp
    # @microposts = tmp.as_json
    @microposts = Micropost.find_by_sql('SELECT "microposts".* FROM "microposts" ORDER BY created_at DESC')
  end

  # GET /microposts/1
  # GET /microposts/1.json
  def show
    #@user = execute_statement('SELECT  "users".* FROM "users" WHERE "users"."id" = ' + @micropost.user_id.to_s + ' LIMIT 1')[0]
    @user = User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1', @micropost.user_id])[0]
    @likes = Like.count_by_sql(['SELECT COUNT(*) FROM "likes" WHERE "likes"."id" = ?', @micropost.id])
    @comments = Comment.count_by_sql(['SELECT COUNT(*) FROM "comments" WHERE "comments"."micropost_id" = ?', @micropost.id])
    @comment_list = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."micropost_id" = ? ORDER BY created_at ASC', @micropost.id])
  end
1
  # GET /microposts/new
  def new
    @micropost = Micropost.new
  end

  # GET /microposts/1/edit
  def edit
  end

  # POST /microposts
  # POST /microposts.json
  def create
    @micropost = Micropost.new(micropost_params)

    @micropost.user = current_user

    respond_to do |format|
      if @micropost.save
        format.html { redirect_to @micropost, notice: 'Micropost was successfully created.' }
        format.json { render :show, status: :created, location: @micropost }
      else
        format.html { render :new }
        format.json { render json: @micropost.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /microposts/1
  # PATCH/PUT /microposts/1.json
  def update

    execute_statement('UPDATE microposts SET content = \'' + params[:micropost][:content].to_s + '\' WHERE id = ' + @micropost.id.to_s)

    #respond_to do |format|
    #  if @micropost.update(micropost_params)
    #    format.html { redirect_to @micropost, notice: 'Micropost was successfully updated.' }
    #    format.json { render :show, status: :ok, location: @micropost }
    #  else
    #    format.html { render :edit }
    #    format.json { render json: @micropost.errors, status: :unprocessable_entity }
    #  end
    #end
    redirect_to micropost_path(@micropost.id)
  end

  # DELETE /microposts/1
  # DELETE /microposts/1.json
  def destroy
    comments = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."micropost_id" = ?', @micropost.id])
    comments.each do |comment|
      comment.destroy
    end
    likes = @micropost.likes
    likes.each do |like|
      execute_statement('DELETE FROM likes WHERE id = ' + like.id.to_s)
    end
    @micropost.destroy
    respond_to do |format|
      format.html { redirect_to microposts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
    # redirect_to microposts_path
  end

  def create_like
    @micropost = Micropost.find_by_sql(['SELECT "microposts".* FROM "microposts" WHERE "microposts"."id" = ? LIMIT 1', params[:id]])[0]
    unless @micropost.have_liked(current_user)
      likes = { user: current_user, micropost: @micropost }
      @like = Like.new(likes)
       @like.save
    else
      # likes = @micropost.likes
      likes = Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."micropost_id" = ?', @micropost.id])
      likes.each do |like|
        if like.user_id == current_user.id
          execute_statement('DELETE FROM likes WHERE id = ' + like.id.to_s)
        end
      end
    end
    redirect_to :back
  end

  def create_comment_like
    @micropost = Micropost.find_by_sql(['SELECT "microposts".* FROM "microposts" WHERE "microposts"."id" =  ? LIMIT 1', params[:id]])[0]
    @comment = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."id" = ? LIMIT 1', params[:comment_id]])[0]
    unless @comment.have_liked(current_user)
      likes = { user: current_user, comment: @comment }
      @like = Like.new(likes)
      time = Time.now.to_s(:db)
      @like.save
    else
      likes = Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."comment_id" = ?', @comment.id])
      likes.each do |like|
        if like.user_id == current_user.id
          execute_statement('DELETE FROM likes WHERE id = ' + like.id.to_s)
        end
      end
    end
    redirect_to micropost_path(@micropost.id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_micropost
       # @micropost = Micropost.find(params[:id])
      #micropost = execute_statement('SELECT  "microposts".* FROM "microposts" WHERE "microposts"."id" = ' + params[:id].to_s + ' LIMIT 1')
      #@micropost = Micropost.new(micropost[0])
      @micropost = Micropost.find_by_sql(['SELECT  "microposts".* FROM "microposts" WHERE "microposts"."id" = ? LIMIT 1', params[:id]])[0]
    end

    def set_edit
      # @micropost = Micropost.find(params[:id])
      @micropost = Micropost.find_by_sql(['SELECT "microposts".* FROM "microposts" WHERE "microposts"."id" = ? LIMIT 1', params[:id]])[0]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def micropost_params
      params.require(:micropost).permit(:user_id, :content)
    end
end
