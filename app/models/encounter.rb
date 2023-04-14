################################################################################
#
# Encounter Model
#
# Copyright (c) 2021 The MITRE Corporation.  All rights reserved.
#
################################################################################

class Encounter < Resource
    
    include ActiveModel::Model

    attr_reader :id, :status, :category, :type, :subject, :episode_of_care, :based_on, :participant, :period,
                :conditions, :hospitalization, :location, :service_provider
    attr_accessor :fhir_queries

    #-----------------------------------------------------------------------------

    def initialize(fhir_encounter, fhir_client)
        @fhir_queries        = []

        @fhir_client         = fhir_client
        @id                  = fhir_encounter.id
        @status              = fhir_encounter.status
        @category            = fhir_encounter.local_class
        @type                = fhir_encounter.type
        @episode_of_care     = fhir_encounter.episodeOfCare  
        @based_on            = fhir_encounter.basedOn        # reference clinicalImpression
        @participant         = fhir_encounter.participant
        @period              = fhir_encounter.period
        @conditions          = fhir_encounter.diagnosis      # condition resource, use, rank
        @hospitalization     = fhir_encounter.hospitalization
        @location            = fhir_encounter.location        # list of locations the patient has been to

        # @service_provider    = service_provider(fhir_encounter.serviceProvider)
        # @subject             = subject(fhir_encounter.subject)
        
        unless fhir_encounter.serviceProvider.nil?
            fhir_response        = @fhir_client.try(:read, nil, fhir_encounter.serviceProvider.reference)
            @service_provider    = fhir_response&.resource&.name
            @fhir_queries        << "#{fhir_response&.request[:method]&.capitalize} #{fhir_response&.request[:url]}"
        end

        unless fhir_encounter.subject.nil?
            fhir_response        = @fhir_client.read(nil, fhir_encounter.subject.reference)
            @subject             = fhir_response&.resource
            @fhir_queries        << "#{fhir_response&.request[:method]&.capitalize} #{fhir_response&.request[:url]}"
        end
    end
    
    # #-----------------------------------------------------------------------------

    # def service_provider(service_provider)
    #     fhir_response        = @fhir_client.try(:read, nil, service_provider&.reference)
    #     @fhir_queries        << "#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"
    #     return fhir_response&.resource
    # end

    # #-----------------------------------------------------------------------------

    # def subject(subject)
    #     fhir_response        = @fhir_client.try(:read, nil, subject&.reference)
    #     @fhir_queries        << "#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"
    #     return fhir_response&.resource
    # end

    #-----------------------------------------------------------------------------

    def reassessment_timepoints
        timepoints = []
        search_param =  { search: 
            { parameters: 
              { 
                "part-of": ["Encounter", @id].join('/') 
              } 
            } 
          }
        fhir_response = @fhir_client.search(FHIR::Encounter, search_param)
        fhir_bundle = fhir_response.resource
        unless fhir_bundle.nil?
            fhir_bundle.entry.each do |encounter|
                timepoints <<  ReAssessmentTimepoint.new(encounter.resource, @fhir_client)
            end
            
        end
        # To display the fhir queries
        @fhir_queries = []
        @fhir_queries << "#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"

        return timepoints
    end
    
    #-----------------------------------------------------------------------------
    
    def providers
        participants = []
        @fhir_queries = []
        
        @participant&.each do |participant|
            fhir_response = @fhir_client.read(nil, participant.individual.reference)
            @fhir_queries << "#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"

            fhir_practitioner = fhir_response.resource
            practitioner = Practitioner.new(fhir_practitioner)

            search_param = {search: {
                parameters: {
                    practitioner: participant.individual.reference 
                    }
                }
            }
            fhir_response = @fhir_client.search(FHIR::PractitionerRole, search_param)
             # To display the fhir queries
            @fhir_queries << "#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"

            fhir_role = fhir_response.resource.entry.first.resource
            role = PractitionerRole.new(fhir_role)

            provider = {}
            provider[:role] = role
            provider[:individual] =  practitioner
            participants << provider
        end

        return participants.compact
    end
    
    #-----------------------------------------------------------------------------

    def diagnoses
        conditions = []
        
        @conditions.each do |condition|
            diagnosis = {}
            fhir_response = @fhir_client.read(nil, condition.condition.reference)
             # To display the fhir queries
            @fhir_queries = []
            @fhir_queries << "#{fhir_response.request[:method].capitalize} #{fhir_response.request[:url]}"

            fhir_condition = fhir_response.resource
            diagnosis[:condition] = Condition.new(fhir_condition)
            diagnosis[:use] = condition.use.coding.map {|code| "#{code.display} (#{code.code})"}.join(", ")

            conditions << diagnosis
        end
        
        return conditions
    end
    
    #-----------------------------------------------------------------------------

    def self.getById(fhir_client, encounter_id)
		obj = fhir_client.read(FHIR::Encounter, encounter_id)
		raise "unable to read encounter resource" unless obj.code == 200
		fhir_encounter = obj.resource
		
		return Encounter.new(fhir_encounter, fhir_client)
	end

    #-----------------------------------------------------------------------------

end