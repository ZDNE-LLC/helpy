Rails.application.routes.draw do

  root to: "locales#redirect_on_locale"
  get 'widget/' => 'widget#index', as: :widget
  get 'widget/thanks' => 'widget#thanks', as: :widget_thanks

  devise_for :users, skip: [:password, :registration, :confirmation], controllers: { omniauth_callbacks: 'omniauth_callbacks' }

  localized do

    root to: "home#index"

    get 'omniauth/:provider' => 'omniauth#localized', as: :localized_omniauth

    #devise_for :users, controllers: {
    #      registrations: 'registrations',
    #      omniauth_callbacks: "callbacks"
    #    }

    devise_for :users, skip: :omniauth_callbacks, controllers: { registrations: 'registrations' }

    resources :knowledgebase, :as => 'categories', :controller => "categories", except: [:new, :edit, :create, :update] do
      #collection do
      #  get 'admin'
      #end
      resources :docs, except: [:new, :edit, :create, :update]
    end

    resources :docs, except: [:new, :edit]
    resources :community, :as => 'forums', :controller => "forums" do
      resources :topics
    end
    resources :topics do
      resources :posts
    end
    resources :posts

    resources :users

    post 'topic/:id/vote' => 'topics#up_vote', as: :up_vote, defaults: { format: 'js' }
    post 'post/:id/vote' => 'posts#up_vote', as: :post_vote, defaults: { format: 'js' }
    get 'result' => 'result#index', as: :result
    get 'tickets' => 'topics#tickets', as: :tickets
    get 'ticket/:id/' => 'topics#ticket', as: :ticket
    get 'cancel_edit_post/:id/' => 'posts#cancel', as: :cancel_edit_post
    get 'locales/select' => 'locales#select', as: :select_locale

  end

  get '/switch_locale' => 'home#switch_locale', as: :switch_locale
  get '/set_client_id' => 'users#set_client_id', as: :set_client_id

  # Admin Routes

  namespace :admin do
    resources :categories do
      resources :docs, except: [:index, :show]
    end
    resources :docs, except: [:index, :show]
    resources :forums# , except: [:index, :show]
    resources :users

    # SearchController Routes
    get '/topic_search' => 'search#topic_search', as: :topic_search
    get '/user_search' => 'search#user_search', as: :user_search

  end

  scope 'admin' do

    get '/' => 'admin#tickets', as: :admin

    # resources :docs, only: [:new, :edit]
    # resources :knowledgebase, :as => 'categories', :controller => "categories", only: [:new, :edit] do
    #   resources :docs, only: [:new, :edit]
    # end

    get '/dashboard' => 'admin#dashboard', as: :admin_dashboard
    post '/content/update_order' => 'admin#update_order', as: :admin_update_order
    get '/tickets' => 'admin#tickets', as: :admin_tickets
    get '/ticket/:id' => 'admin#ticket', as: :admin_ticket
    get '/tickets/new' => 'admin#new_ticket', as: :admin_new_ticket
    post '/tickets/create' => 'admin#create_ticket', as: :admin_create_ticket
    get '/tickets/update' => 'admin#update_ticket', as: :update_ticket, defaults: {format: 'js'}
    get '/tickets/update_multiple' => 'admin#update_multiple_tickets', as: :update_multiple_tickets
    get '/tickets/assign_agent' => 'admin#assign_agent', as: :assign_agent
    get '/tickets/toggle_privacy' => 'admin#toggle_privacy', as: :toggle_privacy
    get '/tickets/:id/toggle' => 'admin#toggle_post', as: :toggle_post
    get '/settings' => 'admin#settings', as: :admin_settings
    put '/update_settings/' => 'admin#update_settings', as: :update_settings

  end




  # Receive email from Griddler
  mount_griddler

  # Mount attachinary
  mount Attachinary::Engine => "/attachinary"

end
