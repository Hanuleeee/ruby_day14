class CafesController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    
    # 전체 카페 목록 보여주는 페이지
    # -> 로그인 하지 않았을때: 전체 카페 목록
    # -> 로그인 했을 때: 유저가 가입한 카페 목록
    def index
        @cafes = Daum.all
    end
    
    # 카페 내용물을 보여주는 페이지(카페의 게시물)
    def show
        @cafe = Daum.find(params[:id])
        # session[:current_cafe] = @cafe.id
    end
    
    #resources를 했기때문에 form_for가 사용가능하다.
    # 카페를 개설하는 페이지
    def new
        @cafe = Daum.new
    end
    
    # 카페를 실제로 개설하는 로직
    def create
        @cafe = Daum.new(daum_params)
        @cafe.master_name = current_user.user_name
        if @cafe.save
            # save 후! cafe와 user을 membership으로 연결
            Membership.create(daum_id: @cafe.id, user_id: current_user.id)
            redirect_to cafe_path(@cafe), flash: {success: "카페가 개설되었습니다."}
            # cafe_path(prefix)에서 cafes/:id로 가야하므로 :id정보가 필요 Thus, (@cafe)를 써줌
        else
            p @cafe.errors  #디버깅용
           redirect_to :back, flash: {danger: "카페 개설에 실패했습니다."}
        end
    end
    
    def join_cafe  # 카페가입
        cafe = Daum.find(params[:cafe_id])
        #사용자가 가입하려는 카페
        if cafe.is_member?(current_user) #사용자설정 메소드 (models/daums.rb에!)
            #가입 실패
            redirect_to :back, flash: {danger: "카페 가입에 실패했습니다."}
        else
            #가입 성공
            Membership.create(daum_id: params[:cafe_id], user_id:current_user.id)
            redirect_to :back, flash: {success: "카페 가입에 성공했습니다."}
        end
        # 이 카페에 현재 로그인된 사용자가 가입이 됐는지 확인
        
        #중복가입을 막을 수 없음
        # 1. 가입버튼을 안보이게 한다. (사용자 화면 조작) ->  Model 코딩(메서드)
        # 2. 중복 가입 체크 후 진행 (서버에서 로직조작) -> Model Validation (가입되어있다면 조인테이블을 안만들어줌?)
        
        # 현재 이 카페에 가입된 유저 중에 지금 로그인한 유저가 있니?
        
    end
    
    # 카페 정보 수정하는 페이지
    def edit
        @cafe = Daum.find(params[:id])
    end
    
    # 카페 정보를 실제로 수정하는 로직
    def update
        @cafe= Daum.update(title: params[:title], description: params[:description])
        redirect_to cafe_path, flash: {success: "카페 정보 수정 완료"}
    end
    
    private
    def daum_params
        # 'daum' 모델에서 title과 description만 받아서 사용하겠다.
        params.require(:daum).permit(:title, :description)
        # :params => {:daum => {"title" => " ", "description" => " "}}
    end
end
