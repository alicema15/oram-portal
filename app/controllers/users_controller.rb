class UsersController < ApplicationController
	before_action :require_login

	def show
		@user = User.find(params[:id])
		@form_hash = {}
		if @user.role == "referrer"
			if !@user.forms.empty? && !@user.forms.where(form_type: 1).empty?
				referrer_forms = @user.forms.where(form_type: 1)
				@form_hash = JSON.parse(referrer_forms.first.form_json)
			end
			render :referrer_profile
		elsif @user.role == "client"
			if !@user.forms.empty? && !@user.forms.where(form_type: 3).empty?
				client_form = @user.forms.where(form_type: 3)
				@form_hash = JSON.parse(client_form.first.form_json)
			end
			render :client_profile
		end
	end

	def edit_referrer_profile
		@referrer = User.find_by_id(params[:id])
		@gender_identity_options = @referrer.gender_identity_options
		@referrer_contact_options = @referrer.referrer_contact_options
		@referrer_LGBTIQ_social_media = @referrer.referrer_LGBTI_social_media
		@referrer_LBGTIQ = @referrer.LGBTIQ_options
		@current_form = @referrer.getFormHash(@referrer.forms.first) || {}
		render :referrer_edit
	end

	def update_referrer_profile
		country_code = params["form_response"]["Country Of Birth"]
		if !country_code.nil? && !country_code.empty?
			country = ISO3166::Country[country_code]
			params["form_response"]["Country Of Birth"] = country.name
		end
		@form_response = params["form_response"].to_json
		@form_type = 1
		@user = User.find_by_id(params[:id])
		@user_form = @user.forms.where(form_type: @form_type).first
		if !@user_form
			@user_form = @user.forms.build({form_json: @form_response, form_type: @form_type, status: "Incomplete", first_name: @user.first_name, last_name: @user.last_name})
		else
			@user_form.update_attribute(:form_json, @form_response)
		end
		if @user_form.save
			flash[:notice] = "Form successfully saved"
			redirect_to referrer_path(@user) and return
		end
		flash[:error] = "Form failed to save"
		redirect_to root_path
	end

	def edit_client_profile
		@client = User.find_by_id(params[:id])
		@client_languages = @client.client_languages
		@turkey_legal_status = User.remove_unsure(@client.turkey_legal_status)
		@yes_no = User.remove_unsure(@client.yes_no_unsure)
		@yes_no_unsure = @client.yes_no_unsure
		@living_situation = User.remove_unsure(@client.living_situation)
		@refugee_claim = @client.refugee_claim
		@sex = @client.sex
		@sexual_orientiation = @client.sexual_orientation
		@client_gender_identity = @client.client_gender_identity
		@client_partner = User.remove_unsure(@client.client_partner)
		@client_openness = User.they_to_you(User.remove_unsure(@client.client_openness))
		@client_dangers = User.they_to_you(@client.client_dangers)
		@client_incident = @client.client_incident
		@mental_illness = @client.mental_illness
		@arrest = @client.arrest
		@documentary_evidence = @client.documentary_evidence
		@no_questionnaire_relationships = @client.no_questionnaire_relationships
		@yes_questionnaire_relationships = @client.yes_questionnaire_relationships
		@professional_capacity = @client.professional_capacity
		@relationship_level = @client.relationship_level
		@turkey_legal_status = @client.turkey_legal_status
		@living_situation = @client.living_situation
		@refugee_claim = @client.refugee_claim
		render :client_edit
	end

	def update_client_profile
		country_code = params["form_response"]["Country Of Birth"]
		if !country_code.nil? && !country_code.empty?
			country = ISO3166::Country[country_code]
			params["form_response"]["Country Of Birth"] = country.name
		end
		@form_response = params["form_response"].to_json
		@form_type = 3
		@user = User.find_by_id(params[:id])
		@user_form = @user.forms.where(form_type: @form_type).first
		if !@user_form
			@user_form = @user.forms.build({form_json: @form_response, form_type: @form_type, status: "Incomplete", first_name: @user.first_name, last_name: @user.last_name})
		else
			@user_form.update_attribute(:form_json, @form_response)
		end
		if @user_form.save
			flash[:notice] = "Form successfully saved"
			redirect_to client_path(@user) and return
		end
		flash[:error] = "Form failed to save"
		redirect_to root_path
	end

	def referrals
		referrer = User.find_by_id(current_user.id)
		@referrals = referrer.forms.where(:form_type => 2)
		render "referrals"
	end

	def refer_client
		@referrer = User.find_by_id(params[:id])
		@gender_identity_options = @referrer.gender_identity_options
		@referrer_contact_options = @referrer.referrer_contact_options
		@referrer_LGBTIQ_social_media = @referrer.referrer_LGBTI_social_media
		@referrer_LBGTIQ = @referrer.LGBTIQ_options
		@client_languages = @referrer.client_languages
		@sex = @referrer.sex
		@yes_no_unsure = @referrer.yes_no_unsure
		@sexual_orientation = @referrer.sexual_orientation
		@client_gender_identity = @referrer.client_gender_identity
		@client_partner = @referrer.client_partner
		@client_openness = @referrer.client_openness
		@client_dangers = @referrer.client_dangers
		@client_incident = @referrer.client_incident
		@mental_illness = @referrer.mental_illness
		@arrest = @referrer.arrest
		@documentary_evidence = @referrer.documentary_evidence
		@no_questionnaire_relationships = @referrer.no_questionnaire_relationships
		@yes_questionnaire_relationships = @referrer.yes_questionnaire_relationships
		@professional_capacity = @referrer.professional_capacity
		@relationship_level = @referrer.relationship_level
		@turkey_legal_status = @referrer.turkey_legal_status
		@living_situation = @referrer.living_situation
		@refugee_claim = @referrer.refugee_claim
		render :refer_client
	end

	def create_referral
		country_code = params["form_response"]["Country Of Birth"]
		if !country_code.nil? && !country_code.empty?
			country = ISO3166::Country[country_code]
			params["form_response"]["Country Of Birth"] = country.name
		end
		client_first_name = params["form_response"]["First Name"]
		client_last_name = params["form_response"]["Surname(s)"]
		@form_response = params["form_response"].to_json
		@form_type = 2
		@user = User.find_by_id(params[:id])
		@user_form = @user.forms.build({first_name: client_first_name, last_name: client_last_name, status: "Incomplete", form_json: @form_response, form_type: @form_type})
		if @user_form.save
			flash[:notice] = "Form successfully saved"
			redirect_to referrals_path(@user) and return
		end
		flash[:error] = "Form failed to save"
		redirect_to root_path
	end

	def client_documents
		@client = User.find_by_id(params[:id])
		@document = @client.case_document
		render :client_documents
	end

	def upload_document
		@client = User.find_by_id(params[:id])
		case_document = params[:case_document]
		@client.update_attribute(:case_document, case_document)
		@client.save!
		redirect_to documents_path(@client)
	end

	private
		def require_login
			if current_user
				if current_user.id != params[:id].to_i
					flash[:error] = "You are not currently logged in to have access to this section"
	      	redirect_to root_path and return
				end
				return
			end
			if !current_admin
				flash[:error] = "You are not currently logged in to have access to this section"
	      redirect_to root_path
			end
		end

end
