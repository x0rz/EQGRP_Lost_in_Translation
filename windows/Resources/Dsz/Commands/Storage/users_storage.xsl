<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	
	<xsl:import href="include/StorageFunctions.xsl"/>
	<xsl:output method="xml" omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates select="Users"/>
			<xsl:call-template name="TaskingInfo">
				<xsl:with-param name="info" select="TaskingInfo"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Users">
		<xsl:apply-templates select="User"/>
	</xsl:template>
	
	<xsl:template match="User">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">User</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">userId</xsl:attribute>
				<xsl:value-of select="@userId"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">name</xsl:attribute>
				<xsl:value-of select="Name"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">fullName</xsl:attribute>
				<xsl:value-of select="FullName"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">comment</xsl:attribute>
				<xsl:value-of select="Comment"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">homeDir</xsl:attribute>
				<xsl:value-of select="HomeDir"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">userShell</xsl:attribute>
				<xsl:value-of select="UserShell"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">primaryGroupId</xsl:attribute>
				<xsl:value-of select="@primaryGroupId"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">numLogons</xsl:attribute>
				<xsl:value-of select="@numLogons"/>
			</xsl:element>
			<xsl:element name="BoolValue">
				<xsl:attribute name="name">passwordExpired</xsl:attribute>
				<xsl:value-of select="@passwdExpired"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">privilege</xsl:attribute>
				<xsl:value-of select="Privilege"/>
			</xsl:element>

			<xsl:choose>
				<xsl:when test="LastLogon">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">lastLogon</xsl:attribute>
						<xsl:value-of select="LastLogon"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="NeverLoggedOn">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">lastLogon</xsl:attribute>
						<xsl:text>Never</xsl:text>
					</xsl:element>
				</xsl:when>
			</xsl:choose>

			<xsl:choose>
				<xsl:when test="AcctExpires">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">accountExpires</xsl:attribute>
						<xsl:value-of select="AcctExpires"/>
					</xsl:element>
				</xsl:when>
				<xsl:when test="AcctNeverExpires">
					<xsl:element name="StringValue">
						<xsl:attribute name="name">accountExpires</xsl:attribute>
						<xsl:text>Never</xsl:text>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">accountExpires</xsl:attribute>
						<xsl:text>Unknown</xsl:text>
					</xsl:element>
				</xsl:otherwise>
			</xsl:choose>

			<xsl:element name="StringValue">
				<xsl:attribute name="name">PasswordLastChanged</xsl:attribute>
				<xsl:value-of select="PasswdLastChanged"/>
			</xsl:element>	
			
			<xsl:apply-templates select="Flags"/>			
		</xsl:element>
	</xsl:template>

      <xsl:template match="Flags">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Flags</xsl:attribute>
			<xsl:apply-templates select="AuthFlags"/>
			<xsl:apply-templates select="AccountFlags"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="AuthFlags">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AuthFlags</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">mask</xsl:attribute>
				<xsl:value-of select="@mask"/>
			</xsl:element>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="AfOpPrint"/>
				<xsl:with-param name="var" select="'authOpPrint'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="AfOpComm"/>
				<xsl:with-param name="var" select="'authOpComm'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="AfOpServer"/>
				<xsl:with-param name="var" select="'authOpServer'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="AfOpAccounts"/>
				<xsl:with-param name="var" select="'authOpAccts'"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template match="AccountFlags">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">AccountFlags</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">mask</xsl:attribute>
				<xsl:value-of select="@mask"/>
			</xsl:element>			
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfScript"/>
				<xsl:with-param name="var" select="'script'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfAccountDisable"/>
				<xsl:with-param name="var" select="'acctDisable'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfHomedirRequired"/>
				<xsl:with-param name="var" select="'homedirReqd'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfPasswordExpired"/>
				<xsl:with-param name="var" select="'passwordExpired'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfTrustedToAuthenticateForDelegation"/>
				<xsl:with-param name="var" select="'trustedToAuthenticateForDelegation'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfPasswdNotReqd"/>
				<xsl:with-param name="var" select="'passwordNotReqd'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfPasswdCantChange"/>
				<xsl:with-param name="var" select="'passwordCantChange'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfLockout"/>
				<xsl:with-param name="var" select="'lockout'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfDontExpirePasswd"/>
				<xsl:with-param name="var" select="'dontExpirePasswd'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfTrustedForDelegation"/>
				<xsl:with-param name="var" select="'trustedForDeleg'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfEncryptedTextPasswordAllowed"/>
				<xsl:with-param name="var" select="'encryptedTextPasswdAllw'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfNotDelegated"/>
				<xsl:with-param name="var" select="'notDelegated'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfSmartCardRequired"/>
				<xsl:with-param name="var" select="'smartcardReqd'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfUseDesKeyOnly"/>
				<xsl:with-param name="var" select="'useDesKeyOnly'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfDontRequirePreauth"/>
				<xsl:with-param name="var" select="'dontRequirePreauth'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfNormalAccount"/>
				<xsl:with-param name="var" select="'normalAcct'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfTempDuplicateAccount"/>
				<xsl:with-param name="var" select="'tempDuplicateAcct'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfWorkstationTrustAccount"/>
				<xsl:with-param name="var" select="'workstatTrustAcct'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfServerTrustAccount"/>
				<xsl:with-param name="var" select="'serverTrustAcct'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfInterdomainTrustAccount"/>
				<xsl:with-param name="var" select="'interdomainTrustAcct'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfMnsLogonAccount"/>
				<xsl:with-param name="var" select="'mnsLogonAccount'"/>
			</xsl:call-template>
			<!-- Deprecated value due to mis-spelling -->
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfMnsLogonAccount"/>
				<xsl:with-param name="var" select="'mnsLogonAcount'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfNoAuthDataRequired"/>
				<xsl:with-param name="var" select="'noAuthDataRequired'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfPartialSecretsAccount"/>
				<xsl:with-param name="var" select="'partialSecretsAccount'"/>
			</xsl:call-template>
			<xsl:call-template name="UserAttribute">
				<xsl:with-param name="flag" select="UfUseAesKeys"/>
				<xsl:with-param name="var" select="'useAesKeys'"/>
			</xsl:call-template>
		</xsl:element>
	</xsl:template>

	<xsl:template name="UserAttribute">
		<xsl:param name="flag"/>
		<xsl:param name="var" />
		
		<xsl:element name="BoolValue">
			<xsl:attribute name="name">
				<xsl:value-of select="$var"/>
			</xsl:attribute>
			<xsl:choose>
				<xsl:when test="$flag">
					<xsl:text>true</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>false</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<xsl:template name="chopZero">
		<xsl:param name="number"/>
		
		<xsl:choose>
			<xsl:when test="starts-with($number, '0')">
				<xsl:call-template name="chopZero">
					<xsl:with-param name="number" select="substring-after($number, '0')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$number"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
			
</xsl:transform>