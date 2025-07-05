public class Constants {
    // API Endpoint and Headers
    public static final String PROPERTY_SEARCH_ENDPOINT = 'https://stoplight.io/mocks/batchdata/batchdata/20349728/property/search';
    public static final String CONTENT_TYPE_HEADER = 'Content-Type';
    public static final String CONTENT_TYPE_JSON = 'application/json';
    public static final String AUTHORIZATION_HEADER = 'Authorization';
    public static final String AUTHORIZATION_TOKEN = 'Bearer API Token';

    // API Response
    public static final String RESULTS = 'results';
    public static final String PROPERTIES = 'properties';
    public static final String ID = '_id';
    public static final String ADDRESS = 'address';
    public static final String STREET = 'street';
    public static final String CITY = 'city';
    public static final String STATE = 'state';
    public static final String ZIP = 'zip';
    public static final String GENERAL = 'general';
    public static final String PROPERTY_TYPE_DETAIL = 'propertyTypeDetail';
    public static final String BUILDING = 'building';
    public static final String YEAR_BUILT = 'yearBuilt';
    public static final String LIVING_AREA_SQFT = 'livingAreaSquareFeet';
    public static final String VALUATION = 'valuation';
    public static final String ESTIMATED_VALUE = 'estimatedValue';
    public static final String MORTGAGE_HISTORY = 'mortgageHistory';
    public static final String LENDER_NAME = 'lenderName';
    public static final String LOAN_AMOUNT = 'loanAmount';
    public static final String INTEREST_RATE = 'interestRate';
    public static final String MONTHLY_PAYMENT = 'monthlyPayment';

    // Response Map
    public static final String DATA = 'data';
    public static final String TOTAL = 'total';

    // Error Messages
    public static final String API_ERROR_PREFIX = 'API Error: ';
    public static final String ERROR_SEARCHING_PROPERTIES_PREFIX = 'Error searching properties: ';
    public static final String ERROR_SAVING_PROPERTIES_PREFIX = 'Error saving properties: ';

    // Property__c field API names
    public static final String PROP_API_ID = 'id';
    public static final String PROP_ADDRESS = 'address';
    public static final String PROP_CITY = 'city';
    public static final String PROP_STATE = 'state';
    public static final String PROP_ZIP = 'zip';
    public static final String PROP_TYPE = 'propertyType';
    public static final String PROP_YEAR_BUILT = 'yearBuilt';
    public static final String PROP_SQFT = 'squareFeet';
    public static final String PROP_EST_VAL = 'estimatedValue';

    // Mortgage__c field API names
    public static final String MORT_LENDER = 'lenderName';
    public static final String MORT_LOAN_AMOUNT = 'loanAmount';
    public static final String MORT_INTEREST_RATE = 'interestRate';
    public static final String MORT_MONTHLY_PAYMENT = 'monthlyPayment';
}