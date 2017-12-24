class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update]
  before_action :set_edit, only: [:destroy, :edit]

  # GET /comments
  # GET /comments.json
  def index
    # @comments = Comment.all
    @comments = Comment.find_by_sql('SELECT "comments".* FROM "comments"')
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
    # @micropost = Micropost.find(params[:micropost_id])
    @micropost = Micropost.find_by_sql(['SELECT "microposts".* FROM "microposts" WHERE "microposts"."id" = ? LIMIT 1', params[:micropost_id]])[0]
    @id = @micropost.id
  end

  # GET /comments/1/edit
  def edit
    @id = @comment.micropost_id
  end

  # POST /comments
  # POST /comments.json
  def create
    @comment = Comment.new(:user => current_user, :micropost_id => params[:comment][:micropost_id], :content => params[:comment][:content])
    sql_parts = ["INSERT INTO comments (content, user_id, micropost_id, created_at, updated_at) VALUES (?, ?, ?, ?, ?)", @comment.content, current_user.id, @comment.micropost_id, Time.now, Time.now]
    sql = ApplicationRecord.send(:sanitize_sql_array, sql_parts)
    result = ApplicationRecord.connection.execute(sql)
    redirect_to micropost_path(params[:comment][:micropost_id])
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    content = ActiveRecord::Base.sanitize(params[:comment][:content])
    id = ActiveRecord::Base.sanitize(@comment.id)
    execute_statement("UPDATE comments SET content = #{content} WHERE id = #{id}")

    #respond_to do |format|
    #  if @comment.update(comment_params)
    #    format.html { redirect_to @comment, notice: 'Comment was successfully updated.' }
    #    format.json { render :show, status: :ok, location: @comment }
    #  else
    #    format.html { render :edit }
    #format.json { render json: @comment.errors, status: :unprocessable_entity }
    #  end
    #end

    redirect_to micropost_path(@comment.micropost)
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    id = @comment.micropost_id
    likes = Like.find_by_sql(['SELECT "likes".* FROM "likes" WHERE "likes"."comment_id" = ?', @comment.id])
    likes.each do |like|
      like_id = ActiveRecord::Base.sanitize(like.id)
      execute_statement("DELETE FROM likes WHERE id = #{like_id}")
    end
    comment_id = ActiveRecord::Base.sanitize(@comment.id)
    execute_statement("DELETE FROM comments WHERE id = #{comment_id}")
    redirect_to micropost_path(id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      # @comment = Comment.find(params[:id])
      @comment = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."id" = ? LIMIT 1', params[:id]])[0]
      # comment = execute_statement('SELECT  "comments".* FROM "comments" WHERE "comments"."id" = ' + params[:id].to_s + ' LIMIT 1')
      # @comment = Comment.new(comment[0])
    end

    def set_edit
      # @comment = Comment.find(params[:id])
      @comment = Comment.find_by_sql(['SELECT "comments".* FROM "comments" WHERE "comments"."id" = ? LIMIT 1', params[:id]])[0]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:user_id, :micropost_id, :content)
    end
end
