class CommentsController < ApplicationController
  
  #require login to view comments
  #after_filter :require_user
  #protect_from_forgery with: :exception
  
  #before_action :check_topic
  before_action :set_comment, only: [:show, :edit, :update, :destroy]
  before_action :before_edit, only: [:new, :create, :like, :neutral, :dislike]#, :show]
  before_action :before_show, only: [:index]

  # GET /:permalink/comments
  # GET /:permalink/comments.json
  def index
    @target = Topic.find_by(:permalink => params[:permalink])
    if @target.nil?()
      format.html { render text: "Error", status: 404 }
    else
      @comments = @target.comments
    end
  end

  # GET /comments/1
  # GET /comments/1.json
  def show
  end

  # GET /:permalink/comments/new
  def new
    @comment = Comment.new
    @comment.owner = @proxy
  end

  # GET /comments/1/edit
  #def edit
  #end

  # POST /:permalink/comments
  # POST /:permalink/comments.json
  def create
    @comment = Comment.new
    @comment.target = @target
    @comment.subject = params[:comment][:subject]
    @comment.body = params[:comment][:body]
    @comment.owner = @proxy
    respond_to do |format|
      if @comment.save!
        format.html { redirect_to "/#{params[:permalink]}/comments", notice: 'Comment was successfully created.' }
        format.json { render action: 'show', status: :created, location: @comment }
      else
        format.html { render action: 'new' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /comments/1
  # PATCH/PUT /comments/1.json
  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html { redirect_to "/#{@comment.target.permalink}/comments", notice: 'Comment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /comments/1
  # DELETE /comments/1.json
  def destroy
    @permalink = @comment.target.permalink
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to "/#{@permalink}/comments" }
      format.json { head :no_content }
    end
  end

  # LIKE/NERUTRAL/DISLIKE /comments/1/(ACTION)
  def like
    c = Comment.find_by(:id => params[:id])
    @proxy.disapprovals.delete(c)
    c.likes << @proxy
    c.save
    redirect_to "/#{c.target.permalink}/comments"
  end

  def neutral
    c = Comment.find_by(:id => params[:id])
    @proxy.approvals.delete(c) 
    @proxy.disapprovals.delete(c) 
    redirect_to "/#{c.target.permalink}/comments"
  end

  def dislike
    c = Comment.find_by(:id => params[:id])
    @proxy.approvals.delete(c) 
    c.dislikes << @proxy
    c.save
    redirect_to "/#{c.target.permalink}/comments"
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_comment
      @comment = Comment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def comment_params
      params.require(:comment).permit(:subject, :body)
    end

    def check_topic
      if !params[:id].nil?
        @target = Comment.find(params[:id]).target
      else
        @target = Topic.find_by(:permalink => params[:permalink])
      end

      if @target.nil?
        format.html { render text: "Error", status: 404 }
      end
    end

    def set_proxy #require login and proxy
      @user = User.find_by(:id => session[:user_id])
      @proxy = @user.proxies.find_by(:topic_id => @target._id)
      return if @proxy
      @proxy = Proxy.new
      @proxy.topic = @target
      @proxy.user = @user
      @proxy.pseudonym = "TEST"#pseudonym_gen
      @proxy.save!
    end

    def before_edit
      check_topic
      set_proxy
    end

    def before_show
      
      check_topic
      if session[:user_id].nil? #use anonymous proxy
        @proxy = Proxy.new
        @proxy.topic = @target
        @proxy.user = @user
        @proxy.pseudonym = "anonymous"
      else #logged in
        
        set_proxy
      end
    end
end