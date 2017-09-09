# TODO *maybe* split into smaller files.
# https://blog.lelonek.me/keep-your-rails-routes-clean-and-organized-83e78f2c11f2

AntCat::Application.routes.draw do
  ActiveAdmin.routes self

  root to: 'catalog#index'

  resources :changes, only: [:show, :index] do
    collection do
      get :unreviewed
      put :approve_all
    end
    member do
      put :approve
      put :undo
      get :confirm_before_undo
    end
  end

  resources :authors, only: [:index, :show, :edit, :update] do
    collection do
      get :autocomplete
    end
    resources :author_names, only: [:update, :create, :destroy]
  end
  resources :merge_authors, only: [:index, :merge]
  post '/merge_authors/merge', to: 'merge_authors#merge'

  namespace :catalog do
    get :autocomplete
    get :show_invalid
    get :show_valid_only
    get "search", to: "search#index"
    get "search/quick_search", to: "search#quick_search", as: "quick_search"
  end
  get 'catalog/:id' => 'catalog#show', as: :catalog
  get 'catalog/:id/wikipedia' => 'catalog#wikipedia_tools'
  get 'catalog/:id/tab/:tab_id' => 'catalog#tab', as: :catalog_tab
  get 'catalog/:id/history' => 'catalog/history#show', as: :taxon_history
  get 'catalog/:id/what_links_here' => 'catalog/what_links_here#index', as: :taxon_what_links_here

  get '/documents/:id/:file_name', to: 'references/downloads#show', file_name: /.+/

  resources :journals do
    collection do
      get :autocomplete
      get :linkable_autocomplete
    end
  end

  namespace :publishers do
    get :autocomplete
  end

  resources :references do
    collection do
      get :autocomplete
      get :linkable_autocomplete
    end

    scope module: :references do
      resources :history, only: :index
      resources :what_links_here, only: :index

      member do
        scope :reviews, controller: :reviews, as: :reviewing do
          post :start
          post :finish
          post :restart
        end

        scope :exports, controller: :exports, as: :export do
          get :wikipedia
        end
      end

      collection do
        scope :exports, controller: :exports, as: :export do
          get :endnote
        end

        resources :latest_additions, only: :index, as: :references_latest_additions
        resources :latest_changes, only: :index, as: :references_latest_changes

        scope :reviews, controller: :reviews, as: :reviewing do
          put :approve_all
        end

        resources :search, only: :index, as: :references_search do
          get :help, on: :collection
        end
      end
    end
  end

  scope module: :types do
    controller :type_specimen_repositories, path: "/types/type_specimen_repositories" do
      get :autocomplete
    end
  end

  scope module: :protonyms do
    controller :localities, path: "/protonyms/localities" do
      get :autocomplete
    end
  end

  resources :taxa, only: [:new, :create, :edit, :update] do
    member do
      controller :taxa_grab_bag do
        put :elevate_to_species
        get :show_children
        get :confirm_before_delete
        delete :destroy
        delete :destroy_unreferenced
        post :reorder_history_items
        get :update_parent # TODO change to put
      end
    end
    collection do
      controller :duplicates do
        get :find_duplicates
        get :find_name_duplicates_only
      end
    end
    resources :taxon_history_items, only: [:update, :create, :destroy]
    resources :reference_sections, only: [:update, :create, :destroy]
    resources :synonyms, only: [:create, :destroy] do
      member do
        put :reverse_synonymy
      end
    end
    resource :convert_to_subspecies, only: [:new, :create]
  end

  resource :default_reference, only: [:update]

  get 'name_pickers/search'

  get 'name_popups/find'
  get 'name_popups/:type/:id' => 'name_popups#show'

  get 'name_fields/find'
  get 'name_fields/:type/:id' => 'name_fields#show'

  resource :reference_field, only: [:show]
  resource :reference_popup, only: [:show]

  devise_for :users
  resources :users, only: [:index, :show] do
    collection do
      get :emails
      get :mentionables
    end
  end

  scope module: 'api' do
    namespace :v1 do
      resources :taxa
      get '/taxa/search/:string', to: 'taxa#search'
      resources :protonyms
      resources :authors
      resources :author_names
      resources :names
      resources :citations
      resources :taxon_history_items
      resources :journals
      resources :places
      resources :publishers
      resources :references
      resources :reference_author_names
      resources :reference_documents
      resources :reference_sections
      resources :synonyms
    end
    # For the next version...
    # namespace :v2 do
    #   resources :taxa
    # end
  end

  resources :antweb_data, only: [:index]

  resources :feedback, only: [:index, :show, :create, :destroy] do
    collection do
      get :autocomplete
    end
    member do
      put :close
      put :reopen
    end
  end

  resources :comments, only: [:index, :create, :edit, :update]

  # TODO nest more Editor's Panel-ish pages under this (issues, site notices, etc).
  scope path: :panel, controller: :editors_panels do
    root action: :index, as: "editors_panel"
    get :invite_users

    scope module: :editors_panels do
      resources :versions, only: [:index, :show]
    end
  end

  get :notifications, to: "notifications#index"

  resources :activities, only: [:index, :show, :destroy]

  resources :site_notices do
    collection do
      post :mark_all_as_read
      post :dismiss
    end
  end

  # Shallow routes for the show action for the activity feed.
  resources :taxon_history_items, only: [:index, :show]
  resources :reference_sections, only: [:index, :show]
  resources :synonyms, only: [:show]

  resources :tooltips do
    collection do
      get :enabled_selectors
      get :render_missing_tooltips
      get :toggle_tooltip_helper
    end

    scope module: :tooltips do
      resources :history, only: :index
    end
  end

  resources :issues do
    collection do
      get :autocomplete
    end
    member do
      put :close
      put :reopen
    end
  end

  namespace :markdown do
    post :preview, action: :preview
    get :formatting_help
    get :symbols_explanations
  end

  resources :database_scripts, only: [:index, :show] do
    member do
      get :source
      get :regenerate
    end
  end

  namespace :beta_and_such do
    # Empty for now.
  end

  unless Rails.env.production?
    namespace :widget_tests do
      get :name_popup_test
      get :name_field_test
      get :reference_popup_test
      get :reference_field_test
      get :taxt_editor_test
      get :tooltips_test
      get :toggle_dev_css
    end
  end
end
