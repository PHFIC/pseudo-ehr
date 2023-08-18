################################################################################
#
# Encounters Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class EncountersController < ApplicationController
    
    before_action :set_fhir_client
    
    def index
        @condition = SessionHandler.from_storage(session.id, 'condition')
        @stage = SessionHandler.from_storage(session.id, 'stage')
        redirect_to(root_path, alert: 'You must select a condition.') and return unless @condition
        redirect_to(root_path, alert: 'You must select a stage.') and return unless @stage
        redirect_to(root_path, alert: 'You must select a FHIR server. Ex: https://hapi.fhir.org/baseR4') and return unless @fhir_client

        # Ex query:
        # https://hapi.fhir.org/baseR4/Encounter?reason-reference:Condition.code=SYPHILIS&reason-reference:Condition.stage=SYPH_PRIMARY&_revinclude=*&_include=*
        fhir_response = @fhir_client.search(FHIR::Encounter, search: {parameters: { 'reason-reference:Condition.code' => @condition, 'reason-reference:Condition.stage' => @stage, '_revinclude' => '*', '_include' => '*' }})
        redirect_to(root_path, alert: 'FHIR Query failed, please check if server is running at URL.') and return unless fhir_response
        @fhir_queries = ["#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"]

        fhir_bundle = fhir_response.resource
        # logger.debug "============================================"
        # logger.debug fhir_bundle.to_json
        # logger.debug "============================================"

        @total = fhir_bundle.total
        @is_paginated = fhir_bundle.link&.any? { |pagination_obj| %w(next previous).any? pagination_obj.relation }

        @encounters = fhir_bundle.entry.select{ |entry| entry.resource.resourceType == 'Encounter' }.map{ |entry| entry.resource }
        @patients_hash = map_reference_to_resource(fhir_bundle, 'Patient')
        # @conditions_hash = map_reference_to_resource(fhir_bundle, 'Condition')
        @locations_hash = map_reference_to_resource(fhir_bundle, 'Location')
        # @care_plans_hash = map_reference_to_resource(fhir_bundle, 'CarePlan')
        
        # GET https://hapi.fhir.org/baseR4/QuestionnaireResponse?patient=Patient/123,Patient/456
        fhir_response = @fhir_client.search(FHIR::QuestionnaireResponse, search: {parameters: { 'patient' => @patients_hash.keys.join(',') }})
        redirect_to(root_path, alert: 'FHIR Query failed, please check if server is running at URL.') and return unless fhir_response
        @fhir_queries << "#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"
        @questionnaire_responses_array = fhir_response.resource.entry.map { |entry| entry.resource }

        # GET https://hapi.fhir.org/baseR4/Specimen?patient=Patient/123,Patient/456
        fhir_response = @fhir_client.search(FHIR::Specimen, search: {parameters: { 'patient' => @patients_hash.keys.join(',') }})
        redirect_to(root_path, alert: 'FHIR Query failed, please check if server is running at URL.') and return unless fhir_response
        @fhir_queries << "#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"
        @specimen_array = fhir_response.resource.entry.map { |entry| entry.resource }

    end
    
    def show
        fhir_response = @fhir_client.read(FHIR::Encounter, params[:id])
        fhir_encounter = fhir_response.resource
        @encounter = Encounter.new(fhir_encounter, @fhir_client) unless fhir_encounter.nil?
        @patient = Patient.new(@encounter.subject, @fhir_client)
        # Display the fhir query being run on the UI to help implementers
        @fhir_queries = ["#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"] + @encounter.fhir_queries
    end
    
    private

    def set_fhir_client
        @fhir_client = SessionHandler.fhir_client(session.id)
    end

    # Params:
    #   bundle: FHIR::Bundle instance
    #   resource: String, FHIR model name
    # Returns a hash { <fhir reference> => <fhir model object> } of all instances of one type of resource in a Bundle
    # Ex: { 'Patient/123' => FHIR::Patient with id=123 }
    def map_reference_to_resource(bundle, resource)
        bundle.entry.select{ |entry| entry.resource.resourceType == resource }.map{ |entry| [resource + '/' + entry.resource.id, entry.resource] }.to_h    
    end

end
