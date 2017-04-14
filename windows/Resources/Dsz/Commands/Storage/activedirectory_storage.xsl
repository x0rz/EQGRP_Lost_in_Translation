<?xml version='1.1' ?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="AdData"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="AdData">
		<xsl:apply-templates select="AdEntry"/>
		<xsl:apply-templates select="AdMode"/>
		<xsl:apply-templates select="AdUser"/>
	</xsl:template>
	
	<xsl:template match="AdEntry">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">GlobalCatalogEntry</xsl:attribute>
			<xsl:variable name="type" select="substring-before(substring-after(Category, 'CN='), ',')" />
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Category</xsl:attribute>
				<xsl:choose>
					<xsl:when test="$type = 'Computer'">
						<xsl:text>COMPUTERS</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'Group'">
						<xsl:text>GROUPS</xsl:text>
					</xsl:when>
					<xsl:when test="$type = 'Person'">
						<xsl:text>USERS</xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">Name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DistinguishedName</xsl:attribute>
				<xsl:value-of select="DistinguishedName"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="AdMode">
		<xsl:element name="ObjectValue">
		<xsl:attribute name="name">AdMode</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">domainName</xsl:attribute>
				<xsl:value-of select="@name"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">mixed</xsl:attribute>
				<xsl:value-of select="@mixed"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="AdUser">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AdUser</xsl:attribute>
			<xsl:call-template name="BoolAttributes">
				<xsl:with-param name="value" select="Flags/AccountDisabled" />
				<xsl:with-param name="var" select="'account_disabled'" />
			</xsl:call-template>
			<xsl:call-template name="BoolAttributes">
				<xsl:with-param name="value" select="Flags/IsAccountLocked" />
				<xsl:with-param name="var" select="'account_locked'" />
			</xsl:call-template>
			<xsl:call-template name="BoolAttributes">
				<xsl:with-param name="value" select="Flags/PasswordRequired" />
				<xsl:with-param name="var" select="'require_password'" />
			</xsl:call-template>
			<xsl:call-template name="BoolAttributes">
				<xsl:with-param name="value" select="Flags/RequireUniquePassword" />
				<xsl:with-param name="var" select="'require_unique_password'" />
			</xsl:call-template>
		
			<xsl:element name="IntValue">
				<xsl:attribute name="name">bad_login_count</xsl:attribute>
				<xsl:value-of select="@badLoginCount" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">password_min_length</xsl:attribute>
				<xsl:value-of select="@passwordMinimumLength" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">max_storage</xsl:attribute>
				<xsl:value-of select="@maxStorage" />
			</xsl:element>

			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="HomeDirectory" />
				<xsl:with-param name="var" select="'home_directory'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="LoginScript" />
				<xsl:with-param name="var" select="'login_script'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="HomePage" />
				<xsl:with-param name="var" select="'home_page'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="Fax" />
				<xsl:with-param name="var" select="'fax'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="TelephonePager" />
				<xsl:with-param name="var" select="'pager'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="TelephoneMobile" />
				<xsl:with-param name="var" select="'mobile_phone'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="TelephoneNumber" />
				<xsl:with-param name="var" select="'office_phone'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="TelephoneHome" />
				<xsl:with-param name="var" select="'home_phone'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="FirstName" />
				<xsl:with-param name="var" select="'first_name'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="LastName" />
				<xsl:with-param name="var" select="'last_name'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="FullName" />
				<xsl:with-param name="var" select="'display_name'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="Department" />
				<xsl:with-param name="var" select="'department'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="Description" />
				<xsl:with-param name="var" select="'description'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="EmailAddress" />
				<xsl:with-param name="var" select="'email_address'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="Manager" />
				<xsl:with-param name="var" select="'manager'" />
			</xsl:call-template>
			<xsl:call-template name="PrintString">
				<xsl:with-param name="value" select="OfficeLocations" />
				<xsl:with-param name="var" select="'office_locations'" />
			</xsl:call-template>

			<xsl:call-template name="PrintDate">
				<xsl:with-param name="var" select="'AccountExpiration'" />
				<xsl:with-param name="time" select="AccountExpirationDate" />
			</xsl:call-template>
			<xsl:call-template name="PrintDate">
				<xsl:with-param name="var" select="'LastFailedLogin'" />
				<xsl:with-param name="time" select="LastFailedLogin" />
			</xsl:call-template>
			<xsl:call-template name="PrintDate">
				<xsl:with-param name="var" select="'LastLogin'" />
				<xsl:with-param name="time" select="LastLogin" />
			</xsl:call-template>
			<xsl:call-template name="PrintDate">
				<xsl:with-param name="var" select="'LastLogoff'" />
				<xsl:with-param name="time" select="LastLogoff" />
			</xsl:call-template>
			<xsl:call-template name="PrintDate">
				<xsl:with-param name="var" select="'ExpirationDate'" />
				<xsl:with-param name="time" select="PasswordExpirationDate" />
			</xsl:call-template>
			<xsl:call-template name="PrintDate">
				<xsl:with-param name="var" select="'LastChanged'" />
				<xsl:with-param name="time" select="PasswordLastChanged" />
			</xsl:call-template>
		
		</xsl:element>
	</xsl:template>

	<xsl:template name="PrintString">
		<xsl:param name="value" />
		<xsl:param name="var" />
		<xsl:element name="StringValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var" />
			</xsl:attribute>
			<xsl:value-of select="$value" />
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="PrintDate">
		<xsl:param name="var" />
		<xsl:param name="time" />
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var" />
			</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">date</xsl:attribute>
				<xsl:value-of select="substring-before($time, 'T')" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">time</xsl:attribute>
				<xsl:value-of select="substring-after(substring-before($time, '.'), 'T')" />
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">type</xsl:attribute>
				<xsl:value-of select="$time/@type" />
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">typeValue</xsl:attribute>
				<xsl:value-of select="$time/@typeValue" />
			</xsl:element>
		</xsl:element>
	</xsl:template>
	<xsl:template name="BoolAttributes">
		<xsl:param name="value" />
		<xsl:param name="var" />
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var" />
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$value">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>