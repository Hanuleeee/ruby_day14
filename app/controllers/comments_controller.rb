class CommentsController < ApplicationController
  def create
    comment = Comment.new # 포스트 id 필요
    comment.content = params[:content]
    comment.post_id = params[:id]
    comment.save
    
    redirect_to :back
  end

  def destroy
    comment= Comment.find(params[:id]) #댓글 id만 필요
    comment.destroy
    
    redirect_to :back
  end
end
