<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/">
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="LocalAddress">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Local</xsl:attribute>
			
			<xsl:call-template name="StoreAddress">
				<xsl:with-param name="element" select="."/>
			</xsl:call-template>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="RemoteAddress">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Remote</xsl:attribute>
			
			<xsl:call-template name="StoreAddress">
				<xsl:with-param name="element" select="."/>
			</xsl:call-template>
			
		</xsl:element>
	</xsl:template>

	<xsl:template match="FrzAddresses">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FrzAddresses</xsl:attribute>
			<xsl:for-each select="FrzAddr">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">FrzAddress</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Address</xsl:attribute>
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FrzLinks">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FrzLinks</xsl:attribute>
			<xsl:for-each select="FrzLink">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">FrzLink</xsl:attribute>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">LinkId</xsl:attribute>
						<xsl:value-of select="@id"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">State</xsl:attribute>
						<xsl:value-of select="@state"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Provider</xsl:attribute>
						<xsl:value-of select="@provider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">CmProvider</xsl:attribute>
						<xsl:value-of select="@cmProvider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">CryptProvider</xsl:attribute>
						<xsl:value-of select="@cryptProvider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">CryptKey</xsl:attribute>
						<xsl:value-of select="CryptKey"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">LinkParameters</xsl:attribute>
						<xsl:value-of select="LinkData"/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FrzRoutes">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FrzRoutes</xsl:attribute>
			<xsl:for-each select="FrzRoute">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">FrzRoute</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Pattern</xsl:attribute>
						<xsl:value-of select="@pattern"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Mask</xsl:attribute>
						<xsl:value-of select="@mask"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">CidrBits</xsl:attribute>
						<xsl:value-of select="@cidrBits"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">Precedence</xsl:attribute>
						<xsl:value-of select="@precedence"/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FrzSecAssociations">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">FrzSecAssociations</xsl:attribute>
			<xsl:for-each select="FrzSecAssoc">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">FrzSecAssociation</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">CheckProvider</xsl:attribute>
						<xsl:value-of select="@checkProvider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">CheckData</xsl:attribute>
						<xsl:value-of select="CheckData"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">CheckType</xsl:attribute>
						<xsl:value-of select="@checkType"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">DstAddress</xsl:attribute>
						<xsl:value-of select="@dstAddr"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">SrcAddress</xsl:attribute>
						<xsl:value-of select="@srcAddr"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Flags</xsl:attribute>
						<xsl:value-of select="@flags"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">KeyExchangeProvider</xsl:attribute>
						<xsl:value-of select="@keyExchangeProvider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">KeyExchangeData</xsl:attribute>
						<xsl:value-of select="KeyExchangeData"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">KeyUpdateProvider</xsl:attribute>
						<xsl:value-of select="@keyUpdateProvider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">KeyUpdateData</xsl:attribute>
						<xsl:value-of select="KeyUpdateData"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">PrivacyProvider</xsl:attribute>
						<xsl:value-of select="@privacyProvider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">PrivacyData</xsl:attribute>
						<xsl:value-of select="PrivacyData"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">SequenceCurrent</xsl:attribute>
						<xsl:value-of select="@sequenceCurrent"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">SequenceMax</xsl:attribute>
						<xsl:value-of select="@sequenceMax"/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="HwAddresses">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">HardwareAddresses</xsl:attribute>
			<xsl:for-each select="HwAddr">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">HardwareAddress</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Address</xsl:attribute>
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="IpAddresses">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">IpAddresses</xsl:attribute>
			<xsl:for-each select="IpAddr">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">IpAddress</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Address</xsl:attribute>
						<xsl:value-of select="IPAddress"/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="Modules">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">Modules</xsl:attribute>
			<xsl:for-each select="Module">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Module</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Id</xsl:attribute>
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ToolVersions">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ToolVersions</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Lla</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Major</xsl:attribute>
					<xsl:value-of select="@llaMajor"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Minor</xsl:attribute>
					<xsl:value-of select="@llaMinor"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Tool</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Major</xsl:attribute>
					<xsl:value-of select="@toolMajor"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Minor</xsl:attribute>
					<xsl:value-of select="@toolMinor"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Patch</xsl:attribute>
					<xsl:value-of select="@toolPatch"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Build</xsl:attribute>
					<xsl:value-of select="@toolBuild"/>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="ConMgrInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">ConnectionManagerInfo</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">BackOff</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Delta</xsl:attribute>
					<xsl:value-of select="@backOffDelta"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Max</xsl:attribute>
					<xsl:value-of select="@backOffMax"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Multiplier</xsl:attribute>
					<xsl:value-of select="@backOffMultiplier"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">ConnectionUpTime</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Max</xsl:attribute>
					<xsl:value-of select="@connectionUpTimeMax"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Min</xsl:attribute>
					<xsl:value-of select="@connectionUpTimeMin"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">InactiveTimeMax</xsl:attribute>
				<xsl:value-of select="@inactiveTimeMax"/>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">NextConnect</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">RangeBegin</xsl:attribute>
					<xsl:value-of select="@nextConnectRangeBegin"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">RangeEnd</xsl:attribute>
					<xsl:value-of select="@nextConnectRangeEnd"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Time</xsl:attribute>
					<xsl:value-of select="@nextConnectTime"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Timeout</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">SequentialConnection</xsl:attribute>
					<xsl:value-of select="@sequentialConnectionTimeout"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">InitialConnection</xsl:attribute>
					<xsl:value-of select="@initialConnectionTimeout"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">SilentRunning</xsl:attribute>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">BaseTime</xsl:attribute>
					<xsl:value-of select="@silentRunningBaseTime"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Duration</xsl:attribute>
					<xsl:value-of select="@silentRunningDuration"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">TimerMark</xsl:attribute>
				<xsl:value-of select="@timerMark"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
	<xsl:template name="StoreAddress"> 
		<xsl:param name="element"/>
		<xsl:element name="StringValue">
			<xsl:attribute name="name">address</xsl:attribute>
			<xsl:value-of select="$element/@address"/>
		</xsl:element>
		<xsl:element name="StringValue">
			<xsl:attribute name="name">arch</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@arch"/>
		</xsl:element>
		<xsl:element name="StringValue">
			<xsl:attribute name="name">CompiledArch</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@compiledArch"/>
		</xsl:element>
		<xsl:element name="StringValue">
			<xsl:attribute name="name">platform</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@platform"/>
		</xsl:element>
		
		<xsl:element name="IntValue">
			<xsl:attribute name="name">major</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@major"/>
		</xsl:element>
		<xsl:element name="IntValue">
			<xsl:attribute name="name">minor</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@minor"/>
		</xsl:element>
		<xsl:element name="IntValue">
			<xsl:attribute name="name">other</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@other"/>
		</xsl:element>
		<xsl:element name="IntValue">
			<xsl:attribute name="name">build</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@build"/>
		</xsl:element>
		
		<xsl:element name="IntValue">
			<xsl:attribute name="name">cLibMajor</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@cLibMajor"/>
		</xsl:element>
		<xsl:element name="IntValue">
			<xsl:attribute name="name">cLibMinor</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@cLibMinor"/>
		</xsl:element>
		<xsl:element name="IntValue">
			<xsl:attribute name="name">cLibRevision</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@cLibRevision"/>
		</xsl:element>
		
		<xsl:element name="IntValue">
			<xsl:attribute name="name">pid</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@pid"/>
		</xsl:element>

		<xsl:element name="StringValue">
			<xsl:attribute name="name">Type</xsl:attribute>
			<xsl:value-of select="$element/OsVersion/@type"/>
		</xsl:element>
		
		<xsl:element name="StringValue">
			<xsl:attribute name="name">Metadata</xsl:attribute>
			<xsl:value-of select="$element/Metadata"/>
		</xsl:element>
	</xsl:template>
  
</xsl:transform>