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
    # Take our search query, sanitize it with ActiveRecord, strip the first and last resulting single quotes (we add these ourselves later), capitalise all letters, remove all but alphanumerical characters + spaces, split it by spaces, and sort by longest to shortest
    if params[:query].present?
      search_terms = ActiveRecord::Base.connection.quote(params[:query])[1..-2].upcase.gsub(/[^A-Z0-9\s]/i, ' ').split(" ").sort_by(&:length).reverse
    end

    if search_terms.present?
      # Form our base SQL query - a LIKE query with our first (and longest) term
      sql_query = "SELECT * FROM national_address_list WHERE autocomplete LIKE '%" + search_terms[0] + "%'"

      # Build our nested query - with each term, we store our results to a temporary named result set (CTE), and then apply our next term on that result set
      # So in most cases, your most ambiguous term will be searched at the end (e.g. a street number), when you've already narrowed down the possible addresses to a few hundred records
      search_terms.drop(1).each_with_index do |term, i|
        sql_query.prepend("WITH results" + i.to_s + " AS (").concat(") SELECT * FROM results" + i.to_s + " WHERE autocomplete LIKE '%" + term + "%'")
      end
      
      # Limit the total results coming back from our query to 10
      sql_query.concat(' LIMIT 10')

      # Run the query
      results = Address.find_by_sql(sql_query)

      # Return either our results, or an indication that we got no results
      unless results.blank?
        render json: {"results":results}, status: :ok
      else
        render json: {"results":"ZERO"}, status: :ok
      end

    else
      render json: {"results":"ZERO"}, status: :ok
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
