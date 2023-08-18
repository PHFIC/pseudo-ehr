module EncounterHelper
    def find_by_subject(array, encounter)
        array.select{ |x| x.subject.reference == encounter.subject.reference }.first
    end
end
