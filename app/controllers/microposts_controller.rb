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
    @user = User.find_by_sql(['SELECT "users".* FROM "users" WHERE "users"."id" = ? LIMIT 1', @micropost.user_id])[0]
    @likes = Like.count_by_sql(['SELECT COUNT(*) FROM "likes" WHERE "likes"."micropost_id" = ?', @micropost.id])
    @comments = Comment.count_by_sql(['SELECT COUNT(*) FROM "comments" WHERE "comments"."micropost_id" = ?', @micropost.id])
    @comment_list = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."micropost_id" = ? ORDER BY created_at ASC', @micropost.id])
  end

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

    if @micropost.content.length > 140
      format.html { render :new }
      format.json { render json: "is too long (maximum is 140 characters)", status: :unprocessable_entity }
    end

    sql_parts = ["INSERT INTO microposts (content, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", @micropost.content, current_user.id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    result = ApplicationRecord.connection.execute(sql)

    respond_to do |format|
      if result
        format.html { redirect_to @micropost, notice: 'Micropost was successfully created.' }
        format.json { render :show, status: :created, location: @micropost }
      else
        format.html { render :new }
        format.json { render json: "Error", status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /microposts/1
  # PATCH/PUT /microposts/1.json
  def update
    sql_parts = ["UPDATE microposts SET content = ?, updated_at = ?  WHERE id = ?", params[:micropost][:content], Time.now, @micropost.id]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    ApplicationRecord.connection.execute(sql)
    redirect_to micropost_path(@micropost.id)
  end

  # DELETE /microposts/1
  # DELETE /microposts/1.json
  def destroy
    comments = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."micropost_id" = ?', @micropost.id])
    comments.each do |comment|
      comment_id = ActiveRecord::Base.sanitize(comment.id)
      execute_statement("DELETE FROM comments WHERE id = #{comment_id}")
    end
    likes = @micropost.likes
    likes = Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "micropost_id" = ?', @micropost.id])
    likes.each do |like|
      like_id = ActiveRecord::Base.sanitize(like.id)
      execute_statement("DELETE FROM likes WHERE id = #{like_id}")
    end
    micropost_id = ActiveRecord::Base.sanitize(@micropost.id)
    execute_statement("DELETE FROM microposts WHERE id = #{micropost_id}")
    respond_to do |format|
      format.html { redirect_to microposts_url, notice: 'Post was successfully destroyed.' }
      format.json { head :no_content }
    end
    # redirect_to microposts_path
  end

  def create_like
    @micropost = Micropost.find_by_sql(['SELECT "microposts".* FROM "microposts" WHERE "microposts"."id" = ? LIMIT 1', params[:id]])[0]
    unless @micropost.have_liked(current_user)
      sql_parts = ["INSERT INTO likes (micropost_id, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", @micropost.id, current_user.id, Time.now, Time.now]
      sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
      ApplicationRecord.connection.execute(sql)

    else
      # likes = @micropost.likes
      likes = Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."micropost_id" = ?', @micropost.id])
      likes.each do |like|
        if like.user_id == current_user.id
          like_id = ActiveRecord::Base.sanitize(like.id)
          execute_statement("DELETE FROM likes WHERE id = #{like_id}")
        end
      end
1    end
    redirect_to :back
  end

  def create_comment_like
    @micropost = Micropost.find_by_sql(['SELECT "microposts".* FROM "microposts" WHERE "microposts"."id" =  ? LIMIT 1', params[:id]])[0]
    @comment = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."id" = ? LIMIT 1', params[:comment_id]])[0]
    unless @comment.have_liked(current_user)
      sql_parts = ["INSERT INTO likes (comment_id, user_id, created_at, updated_at) VALUES (?, ?, ?, ?)", @comment.id, current_user.id, Time.now, Time.now]
      sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
      ApplicationRecord.connection.execute(sql)
    else
      likes = Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."comment_id" = ?', @comment.id])
      likes.each do |like|
        if like.user_id == current_user.id
          like_id = ActiveRecord::Base.sanitize(like.id)
          execute_statement("DELETE FROM likes WHERE id = #{like_id}")
        end
      end
    end
    redirect_to micropost_path(@micropost.id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_micropost
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
