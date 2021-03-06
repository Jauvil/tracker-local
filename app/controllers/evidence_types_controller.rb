# Copyright (c) 2016 21st Century Partnership for STEM Education (21PSTEM)
# see license.txt in this software package
#
class EvidenceTypesController < ApplicationController

  EVIDENCE_TYPE_PARAMS = [
    :name
  ]

  def index
    @evidence_types = EvidenceType.order(:name)
    authorize! :listing, EvidenceType # ensure redirect to login page on timeout
    respond_to do |format|
      format.json # This response is used by forms in old UI?
      format.html # This response is used in Evidence Type Maintenance in New UI
    end
  end

  def new
    @evidence_type = EvidenceType.new
    authorize! :update, @evidence_type # only let maintainers do these things
    respond_to do |format|
      format.js{ render action: :add_edit }
    end
  end

  def create
    @evidence_type = EvidenceType.new(evidence_type_params)
    authorize! :update, @evidence_type # only let maintainers do these things
    if @evidence_type.save
      flash[:notice] = I18n.translate('alerts.successfully') +  I18n.translate('action_titles.created')
    else
      flash[:alert] = I18n.translate('alerts.had_errors') + I18n.translate('action_titles.create')
    end
    respond_to do |format|
      format.js { render action: :saved }
    end
  end

  def edit
    @evidence_type = EvidenceType.find(params[:id])
    authorize! :update, @evidence_type # only let maintainers do these things
    respond_to do |format|
      format.js{ render action: :add_edit }
    end
  end

  def update
    # puts "+++ evidence_type update"
    @evidence_type = EvidenceType.find(params[:id])
    authorize! :update, @evidence_type # only let maintainers do these things
    if @evidence_type.update_attributes(evidence_type_params)
      flash[:notice] = I18n.translate('alerts.successfully') +  I18n.translate('action_titles.updated')
    else
      flash[:alert] = I18n.translate('alerts.had_errors') + I18n.translate('action_titles.update')
    end
    respond_to do |format|
      format.js { render action: :saved }
    end
  end

  private

  def evidence_type_params
    params.require(:evidence_type).permit(EVIDENCE_TYPE_PARAMS)
  end

end
