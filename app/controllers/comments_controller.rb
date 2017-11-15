class CommentsController < ApplicationController
  before_action :set_comment, only: [:show, :update]
  before_action :set_edit, only: [:destroy, :edit]

  # GET /comments
  # GET /comments.json
  def index
    @comments = Comment.all
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /comments/new
  def new
    @comment = Comment.new
    @micropost = Micropost.find(params[:micropost_id])
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
    @comment.save
    redirect_to micropost_path(params[:comment][:micropost_id])
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update

    execute_statement('UPDATE comments SET content = \'' + params[:comment][:content].to_s + '\' WHERE id = ' + @comment.id.to_s)

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
    likes = @comment.likes
    likes.each do |like|
      like.destroy
    end
    @comment.destroy
    redirect_to micropost_path(id)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      # @comment = Comment.find(params[:id])
      comment = execute_statement('SELECT  "comments".* FROM "comments" WHERE "comments"."id" = ' + params[:id].to_s + ' LIMIT 1')
      @comment = Comment.new(comment[0])
    end

    def set_edit
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:user_id, :micropost_id, :content)
    end
end
