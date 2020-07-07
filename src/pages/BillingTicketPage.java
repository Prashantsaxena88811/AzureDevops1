package pages;

import org.openqa.selenium.WebElement;
import org.openqa.selenium.support.FindBy;

public class BillingTicketPage {
	
	  //Locator's
	  //Address of Business Registration:
	  @FindBy(xpath="//input[contains(@name,'rStreet1')]") WebElement street;
	  @FindBy(xpath="//input[contains(@name,'rCity')]") WebElement city;
	  @FindBy(xpath="//input[contains(@name,'rState')]") WebElement state;
	  @FindBy(xpath="//input[contains(@name,'rCountry')]") WebElement country;
	  @FindBy(xpath="//input[contains(@name,'rzipCode')]") WebElement zipCode;
	  
	  //Billing Contact:
	  @FindBy(xpath="//input[contains(@name,'contName')]") WebElement name;
	  @FindBy(xpath="//input[contains(@name,'contEmail')]") WebElement email;
	  @FindBy(xpath="//input[contains(@name,'contPhone')]") WebElement phone;
	  
	  //CheckBox for same Address
	  @FindBy(css = ".slds-form-element__control.slds-checkbox") WebElement addCheckBox;
	  
	  //Billing Address:
	  @FindBy(xpath="//input[contains(@name,'bStreet1')]") WebElement billingStreet;
	  @FindBy(xpath="//input[contains(@name,'bCity')]") WebElement billingCity;
	  @FindBy(xpath="//input[contains(@name,'bState')]") WebElement billingState;
	  @FindBy(xpath="//input[contains(@name,'bCountry')]") WebElement billingCountry;
	  @FindBy(xpath="//input[contains(@name,'bzipCode')]") WebElement billingZipCode;
	  @FindBy(css = ".slds-button.slds-button_brand") WebElement saveButton;
	  
	
		public void setRegStreet(String rStreet) {
			street.sendKeys(rStreet);
		}

		public void setRegCity(String rCity) {
			city.sendKeys(rCity);
		}
		
		public void setRegState(String rState) {
			state.sendKeys(rState);
		}
		
		public void setRegCountry(String rCountry) {
			country.sendKeys(rCountry);
		}

		public void setRegZipCode(String rZipCode) {
			zipCode.sendKeys(rZipCode);
		}

		public void setName(String Name) {
			name.sendKeys(Name);
		}

		public void setEmail(String Email) {
			email.sendKeys(Email);
		}

		public void setState(String Phone) {
			phone.sendKeys(Phone);
		}

		public void selectCheckBox() {
			if (addCheckBox.isSelected()) {
				System.out.println("CheckBox Already selected");
			} else {
				addCheckBox.click();
			}
		}

		public void setBillingStreet(String bStreet) {
			billingStreet.sendKeys(bStreet);
		}

		public void setBillingState(String bState) {
			billingState.sendKeys(bState);
		}
		
		public void setBillingCity(String bCity) {
			billingCity.sendKeys(bCity);
		}

		public void setBillingCountry(String bCountry) {
			billingCountry.sendKeys(bCountry);
		}

		public void setBillingZipCode(String bZipCode) {
			billingZipCode.sendKeys(bZipCode);
		}
		
		public void saveButton() {
			saveButton.click();			
		}
		
}
