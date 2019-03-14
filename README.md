# audress - Australian Address Validation API

A RESTful API for searching and validating any Australian address. It's designed to work with a flat table Geocoded National Address File (G-NAF) database stored on PostgreSQL, which you can generate with my [G-NAF Importer](https://github.com/qapn/gnaf-importer).

The main search endpoint will build a query with nested temporary named result sets (CTEs), allowing for quick querying against over 13 million addresses.

The underlying raw G-NAF data is licensed CC BY 4.0, and is provided by the Australian government.

## Setup

1. Build and configure a G-NAF flat table database with the [G-NAF Importer](https://github.com/qapn/gnaf-importer).
1. Clone this repository.
1. Start a local Redis instance in Docker:
    ```
    docker run --name redis -d --restart always -p 6379:6379 redis
    ```
1. Update and install all required gems:
    ```
    bundle update
    ```
1. Start the server:
    ```
    rails s
    ```

docker run --name redis -d --restart always -p 6379:6379 redis

## Usage

### Autocomplete

  Returns up to 10 matching address records from a search term.

* **URL**

  /addresses/autocomplete

* **Method:**

  `POST` or `GET`
  
*  **URL Params**

   `query=[space separated search terms]`

* **Success Response:**

  * **Input:**      
    * `182 church street parramatta`
  * **Response:**
    * `Status: 200 OK`
    * `{ "results": [ { "address_detail_pid": "GANSW711121522", "street_locality_pid": "NSW2810040", "locality_pid": "NSW3184", "building_name": null, "lot_number_prefix": null, "lot_number": null, "lot_number_suffix": null, "flat_type": null, "flat_number_prefix": null, "flat_number": null, "flat_number_suffix": null, "level_type": null, "level_number_prefix": null, "level_number": null, "level_number_suffix": null, "number_first_prefix": null, "number_first": 182, "number_first_suffix": null, "number_last_prefix": null, "number_last": 184, "number_last_suffix": null, "street_name": "CHURCH", "street_class_code": "C", "street_class_type": "CONFIRMED", "street_type_code": "STREET", "street_suffix_code": null, "street_suffix_type": null, "locality_name": "PARRAMATTA", "state_abbreviation": "NSW", "postcode": "2150", "latitude": "-33.81618626", "longitude": "151.004568", "geocode_type": "PROPERTY CENTROID", "confidence": 0, "alias_principal": "P", "primary_secondary": null, "legal_parcel_id": null, "date_created": "2007-10-23", "autocomplete": "182-184 CHURCH STREET, PARRAMATTA NSW 2150" } ] }`
 
* **No Results Response:**

  * **Input:**      
    * `1600 pennsylvania avenue washington`
  * **Response:**
    * `Status: 204 No Content`

### G-NAF ID Lookup

  Returns the record matching a G-NAF ID.

* **URL**

  /addresses/:id

* **Method:**

  `GET`
  
* **Response:**

  * Identical to the autocomplete endpoint.

## FAQ
 
* **I searched for X address/business and the result was incorrect/missing!**

    The data is put together by a combination of every Australian state and territory government along with the federal government. You can contact the relevant state/territory and get them to fix it in a subsequent G-NAF release.

* **I got an error/I'm unable to get this running!**

    It could be something simple! Please open an issue on this repository with some details about your problem, and I'd be happy to help you.
