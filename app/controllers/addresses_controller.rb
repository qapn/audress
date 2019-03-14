class AddressesController < ApplicationController
  before_action :set_address, only: [:show, :update, :destroy]

  # GET /addresses
  def index
    render json: {"gnaf-api-status":"online"}, status: :ok
  end

  # GET /addresses/1
  def show
    if @address.present?
      render json: @address, status: :ok
    else
      render json: {"results":"ZERO"}, status: :ok
    end
  end

  # POST /addresses/autocomplete
  def autocomplete
    # Don't do anything until we have more than 4 characters
    unless params[:query].present? && params[:query].length > 4
      render status: :no_content
      return
    end

    # Take our search query, sanitize it with ActiveRecord, strip the first and last resulting single quotes (we add these ourselves later), capitalise all letters, remove all but alphanumerical characters + spaces, split it by spaces
    search_terms = ActiveRecord::Base.connection.quote(params[:query])[1..-2].upcase.gsub(/[^A-Z0-9\s]/i, ' ').split(" ")

    # Super wildcard query - this is our first attempt to find some records. If we get results here, we'll use them before resorting to a recursive CTE query
    if search_terms.present?
      results = Address.find_by_sql("SELECT * FROM national_address_list WHERE autocomplete LIKE '%" + search_terms.join('%') + "%' LIMIT 10")

      # Return our results and finish, or just continue on
      unless results.blank?
        render json: {"results":results}, status: :ok
        return
      end
    end

    # Sort our terms from before by longest to shortest, in preparation for our recursive CTE query
    search_terms = search_terms.sort_by(&:length).reverse

    if search_terms.present?
      # Form our base SQL query - a LIKE query with our first (and longest) term - or regex query with a number
      if search_terms[0].numeric?
        sql_query = "SELECT * FROM national_address_list WHERE autocomplete ~ '(^|[^\\d])(" + search_terms[0] + ")([^\\d]|$)'"
      else
        sql_query = "SELECT * FROM national_address_list WHERE autocomplete LIKE '%" + search_terms[0] + "%'"
      end

      # Build our nested query - with each term, we store our results to a common table expression (CTE), and then apply our next term on that result set
      # So in most cases, your most ambiguous term will be searched at the end (e.g. a street number), when you've already narrowed down the possible addresses to a few hundred records
      search_terms.drop(1).each_with_index do |term, i|
        if term.numeric?
          sql_query.prepend("WITH results" + i.to_s + " AS (").concat(") SELECT * FROM results" + i.to_s + " WHERE autocomplete ~ '(^|[^\\d])(" + term + ")([^\\d]|$)'")
        else
          sql_query.prepend("WITH results" + i.to_s + " AS (").concat(") SELECT * FROM results" + i.to_s + " WHERE autocomplete LIKE '%" + term + "%'")
        end
      end
      
      # Limit the total results coming back from our query to 10
      sql_query.concat(' LIMIT 10')

      # Run the query
      results = Address.find_by_sql(sql_query)

      # Return either our results, or an indication that we got no results
      unless results.blank?
        render json: {"results":results}, status: :ok
        return
      else
        render status: :no_content
        return
      end

    else
      render status: :no_content
      return
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address
      @address = Address.find_by(address_detail_pid: params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def address_params
      params.require(:address).permit(:address_detail_pid, :street_locality_pid, :locality_pid, :building_name, :lot_number_prefix, :lot_number, :lot_number_suffix, :flat_type, :flat_number_prefix, :flat_number, :flat_number_suffix, :level_type, :level_number_prefix, :level_number, :level_number_suffix, :number_first_prefix, :number_first, :number_first_suffix, :number_last_prefix, :number_last, :number_last_suffix, :street_name, :street_class_code, :street_class_type, :street_type_code, :street_suffix_code, :street_suffix_type, :locality_name, :state_abbreviation, :postcode, :latitude, :longitude, :geocode_type, :confidence, :alias_principal, :primary_secondary, :legal_parcel_id, :date_created, :autocomplete)
    end
end
