<?xml version='1.1' ?>

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:import href="include/StandardTransforms.xsl" />
	
	<xsl:template match="AdData">
		<xsl:apply-templates select="AdMode"/>
		<xsl:apply-templates select="AdEntry"/>
		<xsl:apply-templates select="AdUser"/>
	</xsl:template>
	
	<xsl:template match="AdMode">
		<xsl:text>Current Domain : </xsl:text>
		<xsl:value-of select="@name" />
		<xsl:call-template name="PrintReturn"/>
		
		<xsl:text>          Mode : </xsl:text>
		<xsl:choose>
		<xsl:when test="contains(@mixed, 'true')">
		<xsl:text>Mixed</xsl:text>
		</xsl:when>
		<xsl:otherwise>
		<xsl:text>Native</xsl:text>
		</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn"/>
	</xsl:template>
	
	<xsl:template match="AdEntry">
		<xsl:variable name="type" select="substring-before(substring-after(Category, 'CN='), ',')" />
		<xsl:value-of select="$type" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintTab" />
		<xsl:value-of select="Name" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintTab" />
		<xsl:value-of select="DistinguishedName" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>-------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="AdUser">
		<xsl:text>-------------User Account Information------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text> Personal Data for </xsl:text>
		<xsl:value-of select="Name" />
		<xsl:text> : </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'First Name'" />
			<xsl:with-param name="value" select="FirstName" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Last Name'" />
			<xsl:with-param name="value" select="LastName" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Display Name'" />
			<xsl:with-param name="value" select="FullName" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Department'" />
			<xsl:with-param name="value" select="Department" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Description'" />
			<xsl:with-param name="value" select="Description" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'EmailAddress'" />
			<xsl:with-param name="value" select="EmailAddress" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Manager'" />
			<xsl:with-param name="value" select="Manager" />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'OfficeLocations'" />
			<xsl:with-param name="value" select="OfficeLocations" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn" />
		<xsl:text> Account Information: </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="name" select="'Account Expiration'" />
			<xsl:with-param name="value" select="AccountExpirationDate" />
		</xsl:call-template>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="name" select="'LastFailedLogin'" />
			<xsl:with-param name="value" select="LastFailedLogin" />
		</xsl:call-template>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="name" select="'LastLogin'" />
			<xsl:with-param name="value" select="LastLogin" />
		</xsl:call-template>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="name" select="'LastLogoff'" />
			<xsl:with-param name="value" select="LastLogoff" />
		</xsl:call-template>
		<xsl:call-template name="PrintBool">
			<xsl:with-param name="name" select="'Account Disabled'" />
			<xsl:with-param name="value" select="not(boolean(Flags/AccountDisabled))" />
		</xsl:call-template>
		<xsl:call-template name="PrintBool">
			<xsl:with-param name="name" select="'Account Locked'" />
			<xsl:with-param name="value" select="not(boolean(Flags/IsAccountLocked))" />
		</xsl:call-template>
		<xsl:text>       BadLoginCount : </xsl:text>
		<xsl:value-of select="@badLoginCount" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text> Password Information : </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>      Minimum Length : </xsl:text>
		<xsl:value-of select="@passwordMinimumLength" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintBool">
			<xsl:with-param name="name" select="'Required'" />
			<xsl:with-param name="value" select="not(boolean(Flags/PasswordRequired))" />
		</xsl:call-template>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="name" select="'Expiration Date'" />
			<xsl:with-param name="value" select="PasswordExpirationDate" />
		</xsl:call-template>
		<xsl:call-template name="PrintDate">
			<xsl:with-param name="name" select="'Last Changed'" />
			<xsl:with-param name="value" select="PasswordLastChanged" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn" />
		<xsl:text> Telephone Numbers : </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Office'" />
			<xsl:with-param name="value" select="TelephoneNumber/." />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Home'" />
			<xsl:with-param name="value" select="TelephoneHome/." />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Mobile'" />
			<xsl:with-param name="value" select="TelephoneMobile/." />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Pager'" />
			<xsl:with-param name="value" select="TelephonePager/." />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Fax Number'" />
			<xsl:with-param name="value" select="FaxNumber/." />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn" />
		<xsl:text> Additional Data : </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'Home Directory'" />
			<xsl:with-param name="value" select="HomeDirectory/." />
		</xsl:call-template>
		<xsl:text>          MaxStorage : </xsl:text>
		<xsl:value-of select="@maxStorage" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'HomePage'" />
			<xsl:with-param name="value" select="HomePage/." />
		</xsl:call-template>
		<xsl:call-template name="PrintString">
			<xsl:with-param name="name" select="'LoginScript'" />
			<xsl:with-param name="value" select="LoginScript/." />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template name="PrintString">
		<xsl:param name="name" />
		<xsl:param name="value" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="20 - string-length($name)" />
		</xsl:call-template>
		<xsl:value-of select="$name" />
		<xsl:text> : </xsl:text>
		<xsl:value-of select="$value" />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template name="PrintBool">
		<xsl:param name="name" />
		<xsl:param name="value" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="20 - string-length($name)" />
		</xsl:call-template>
		<xsl:value-of select="$name" />
		<xsl:text> : </xsl:text>
		<xsl:choose>
			<xsl:when test="$value = true">
				<xsl:text>Yes</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>No</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template name="PrintDate">
		<xsl:param name="name" />
		<xsl:param name="value" />
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="20 - string-length($name)" />
		</xsl:call-template>
		<xsl:value-of select="$name" />
		<xsl:text> : </xsl:text>
		<xsl:choose>
			<xsl:when test="$value">
				<xsl:call-template name="PrintTime">
					<xsl:with-param name="dateTime" select="$value" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>Unknown</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template name="PrintTime">
		<xsl:param name="dateTime" />
		<xsl:variable name="date" select="substring-before($dateTime, 'T')" />
		<xsl:variable name="year" select="substring-before($date, '-')" />
		<xsl:variable name="month" select="substring-before(substring-after($date, '-'), '-')" />
		<xsl:variable name="day" select="substring-after( substring-after($date, '-'), '-')" />
		<xsl:variable name="time" select="substring-after($dateTime, 'T')" />
		<xsl:variable name="hour" select="substring-before($time, ':')" />
		<xsl:variable name="minute" select="substring-before(substring-after($time, ':'), ':')" />
		<xsl:variable name="second" select="substring-before(substring-after( substring-after($time, ':'), ':'), '.')" />
		<xsl:value-of select="$month" />
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$day" />
		<xsl:text>/</xsl:text>
		<xsl:value-of select="$year" />
		<xsl:text> </xsl:text>
		<xsl:value-of select="$hour" />
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$minute" />
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$second" />
	</xsl:template>
	
</xsl:transform>