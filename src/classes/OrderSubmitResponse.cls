public class OrderSubmitResponse {

	public class Response {
		public String orderNumberFromSource;
		public String orderStatus;
		public String orderStatusDesc;
	}

	public class Meta {
		public String status;
		public Integer statusCode;
		public List<String> additionalInfo;
	}

	public Meta meta;
	public Response response;

	
	public static OrderSubmitResponse parse(String json) {
		return (OrderSubmitResponse) System.JSON.deserialize(json, OrderSubmitResponse.class);
	}
}