################################################################################
#
# Welcome Controller
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

class WelcomeController < ApplicationController

  def index
    # Start from scratch
    SessionHandler.disconnect(session.id) if session.id
  end

  def create
    server_url = params[:server_url].empty? ? DEFAULT_SERVER : params[:server_url].strip
    SessionHandler.fhir_client(session.id, server_url)
    redirect_to patients_path
  end

  def restart
    redirect_to root_path, notice: "Restarted Pseudo EHR."
  end

end


