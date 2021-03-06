require 'spec_helper'

describe Spree::Core::ControllerHelpers::Auth, type: :controller do
  controller do
    include Spree::Core::ControllerHelpers::Auth
    def index; render text: 'index'; end
  end

  describe '#current_ability' do
    it 'returns Spree::Ability instance' do
      expect(controller.current_ability.class).to eq Spree::Ability
    end
  end

  describe '#redirect_back_or_default' do
    controller do
      include Spree::Core::ControllerHelpers::Auth
      def index; redirect_back_or_default('/'); end
    end
    it 'redirects to session url' do
      session[:spree_user_return_to] = '/redirect'
      get :index
      expect(response).to redirect_to('/redirect')
    end
    it 'redirects to default page' do
      get :index
      expect(response).to redirect_to('/')
    end
  end

  describe '#set_guest_token' do
    controller do
      include Spree::Core::ControllerHelpers::Auth
      def index
        set_guest_token
        render text: 'index'
      end
    end
    it 'sends cookie header' do
      get :index
      expect(response.cookies['guest_token']).not_to be_nil
    end
  end

  describe '#store_location' do
    it 'sets session return url' do
      controller.stub(request: stub(fullpath: '/redirect'))
      controller.store_location
      expect(session[:spree_user_return_to]).to eq '/redirect'
    end
  end

  describe '#try_spree_current_user' do
    it 'calls spree_current_user when define spree_current_user method' do
      controller.should_receive(:spree_current_user)
      controller.try_spree_current_user
    end
    it 'calls current_spree_user when define current_spree_user method' do
      controller.should_receive(:current_spree_user)
      controller.try_spree_current_user
    end
    it 'returns nil' do
      expect(controller.try_spree_current_user).to eq nil
    end
  end

  describe '#unauthorized' do
    controller do
      include Spree::Core::ControllerHelpers::Auth
      def index; unauthorized; end
    end
    context 'when logged in' do
      before do
        controller.stub(try_spree_current_user: true)
      end
      it 'redirects unauthorized path' do
        get :index
        expect(response).to redirect_to('/unauthorized')
      end
    end
    context 'when guest user' do
      before do
        controller.stub(try_spree_current_user: false)
      end
      it 'redirects login path' do
        controller.stub(spree_login_path: '/login')
        get :index
        expect(response).to redirect_to('/login')
      end
      it 'redirects root path' do
        controller.stub(root_path: '/root_path')
        get :index
        expect(response).to redirect_to('/root_path')
      end
    end
  end
end
