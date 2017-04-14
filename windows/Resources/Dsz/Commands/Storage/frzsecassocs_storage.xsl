<?xml version='1.1' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

	<xsl:output method="xml" omit-xml-declaration="yes"/>

	<xsl:template match="/"> 
		<xsl:element name="StorageObjects">
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="TaskingInfo">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">TaskingInfo</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">TaskType</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Value</xsl:attribute>
					<xsl:value-of select="TaskType"/>
				</xsl:element>
			</xsl:element>
			<xsl:if test="SrcAddr">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">SrcAddr</xsl:attribute>
					<xsl:value-of select="SrcAddr"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="DstAddr">
				<xsl:element name="StringValue">
					<xsl:attribute name="name">DstAddr</xsl:attribute>
					<xsl:value-of select="DstAddr"/>
				</xsl:element>
			</xsl:if>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Flags</xsl:attribute>
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">SequenceCycle</xsl:attribute>
					<xsl:choose>
						<xsl:when test="FlagSequenceCycle">
							<xsl:text>true</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>false</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">IsReceive</xsl:attribute>
					<xsl:choose>
						<xsl:when test="FlagIsReceive">
							<xsl:text>true</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>false</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">UseReplayProtection</xsl:attribute>
					<xsl:choose>
						<xsl:when test="FlagUseReplay">
							<xsl:text>true</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>false</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
			<xsl:if test="KeyExchange">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">KeyExchange</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Provider</xsl:attribute>
						<xsl:value-of select="KeyExchange/@provider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Parameters</xsl:attribute>
						<xsl:value-of select="KeyExchange/Params"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="Verification">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Verification</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Provider</xsl:attribute>
						<xsl:value-of select="Verification/@provider"/>
					</xsl:element>
					<xsl:element name="IntValue">
						<xsl:attribute name="name">Type</xsl:attribute>
						<xsl:value-of select="Verification/@type"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Parameters</xsl:attribute>
						<xsl:value-of select="Verification/Params"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="Privacy">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">Privacy</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Provider</xsl:attribute>
						<xsl:value-of select="Privacy/@provider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Parameters</xsl:attribute>
						<xsl:value-of select="Privacy/Params"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="KeyUpdate">
				<xsl:element name="ObjectValue">
					<xsl:attribute name="name">KeyUpdate</xsl:attribute>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Provider</xsl:attribute>
						<xsl:value-of select="KeyUpdate/@provider"/>
					</xsl:element>
					<xsl:element name="StringValue">
						<xsl:attribute name="name">Parameters</xsl:attribute>
						<xsl:value-of select="KeyUpdate/Params"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:if test="SequenceFirst">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">SequenceCurrent</xsl:attribute>
					<xsl:value-of select="SequenceFirst"/>
				</xsl:element>
			</xsl:if>
			<xsl:if test="SequenceLast">
				<xsl:element name="IntValue">
					<xsl:attribute name="name">SequenceMaximum</xsl:attribute>
					<xsl:value-of select="SequenceLast"/>
				</xsl:element>
			</xsl:if>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="FrzSecAssocs">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SecurityAssociations</xsl:attribute>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">NumSecAssocs</xsl:attribute>
				<xsl:value-of select="@numSecAssocs"/>
			</xsl:element>
			<xsl:apply-templates select="SecAssoc"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="SecAssoc">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SecurityAssociation</xsl:attribute>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">SrcAddr</xsl:attribute>
				<xsl:value-of select="@srcAddr"/>
			</xsl:element>
			<xsl:element name="StringValue">
				<xsl:attribute name="name">DstAddr</xsl:attribute>
				<xsl:value-of select="@dstAddr"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">FlagsValue</xsl:attribute>
				<xsl:value-of select="@flags"/>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Flags</xsl:attribute>
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">SequenceCycle</xsl:attribute>
					<xsl:choose>
						<xsl:when test="FlagSequenceCycle">
							<xsl:text>true</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>false</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">IsReceive</xsl:attribute>
					<xsl:choose>
						<xsl:when test="FlagReceive">
							<xsl:text>true</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>false</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
				<xsl:element name="BoolValue">
					<xsl:attribute name="name">UseReplayProtection</xsl:attribute>
					<xsl:choose>
						<xsl:when test="FlagUseReplayPrevention">
							<xsl:text>true</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>false</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:element>
			</xsl:element>
		</xsl:element>
	</xsl:template>

	<xsl:template match="FrzSecAssoc">
		<xsl:element name="ObjectValue">
			<xsl:attribute name="name">SecurityAssociationInfo</xsl:attribute>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">KeyExchange</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Provider</xsl:attribute>
					<xsl:value-of select="KeyExchange/@provider"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">ProviderName</xsl:attribute>
					<xsl:value-of select="KeyExchange/@providerName"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Parameters</xsl:attribute>
					<xsl:value-of select="KeyExchange/Parameters"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Verification</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Provider</xsl:attribute>
					<xsl:value-of select="Verification/@provider"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">ProviderName</xsl:attribute>
					<xsl:value-of select="Verification/@providerName"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">TypeName</xsl:attribute>
					<xsl:value-of select="Verification/@typeName"/>
				</xsl:element>
				<xsl:element name="IntValue">
					<xsl:attribute name="name">Type</xsl:attribute>
					<xsl:value-of select="Verification/@type"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Parameters</xsl:attribute>
					<xsl:value-of select="Verification/Parameters"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">Privacy</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Provider</xsl:attribute>
					<xsl:value-of select="Privacy/@provider"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">ProviderName</xsl:attribute>
					<xsl:value-of select="Privacy/@providerName"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Parameters</xsl:attribute>
					<xsl:value-of select="Privacy/Parameters"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="ObjectValue">
				<xsl:attribute name="name">KeyUpdate</xsl:attribute>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Provider</xsl:attribute>
					<xsl:value-of select="KeyUpdate/@provider"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">ProviderName</xsl:attribute>
					<xsl:value-of select="KeyUpdate/@providerName"/>
				</xsl:element>
				<xsl:element name="StringValue">
					<xsl:attribute name="name">Parameters</xsl:attribute>
					<xsl:value-of select="KeyUpdate/Parameters"/>
				</xsl:element>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SequenceCurrent</xsl:attribute>
				<xsl:value-of select="SequenceNumber"/>
			</xsl:element>
			<xsl:element name="IntValue">
				<xsl:attribute name="name">SequenceMaximum</xsl:attribute>
				<xsl:value-of select="SequenceNumberMax"/>
			</xsl:element>
		</xsl:element>
	</xsl:template>
	
</xsl:transform>

