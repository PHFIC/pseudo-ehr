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
        @fhir_queries = ["#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"]

        fhir_bundle = fhir_response.resource
        logger.debug "============================================"
        logger.debug fhir_bundle.to_json
        logger.debug "============================================"

        @total = fhir_bundle.total
        @is_paginated = fhir_bundle.link&.any? { |pagination_obj| %w(next previous).any? pagination_obj.relation }

        @encounters = fhir_bundle.entry.select{ |entry| entry.resource.resourceType == 'Encounter' }.map{ |entry| entry.resource }
        @patient_hash = fhir_bundle.entry.select{ |entry| entry.resource.resourceType == 'Patient' }.map{ |entry| [entry.resource.id, entry.resource] }.to_h
        @condition_hash = fhir_bundle.entry.select{ |entry| entry.resource.resourceType == 'Condition' }.map{ |entry| [entry.resource.id, entry.resource] }.to_h
        @location_hash = fhir_bundle.entry.select{ |entry| entry.resource.resourceType == 'Location' }.map{ |entry| [entry.resource.id, entry.resource] }.to_h
        @care_plan_hash = fhir_bundle.entry.select{ |entry| entry.resource.resourceType == 'CarePlan' }.map{ |entry| [entry.resource.id, entry.resource] }.to_h
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
    
end
