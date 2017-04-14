<?xml version='1.0' ?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:import href="include/StandardTransforms.xsl" />
	
	<xsl:template match="Jobs">
		<xsl:apply-templates select="NetJob"/>
		<xsl:apply-templates select="AtHeader"/>
		<xsl:apply-templates select="AtJob"/>
		<xsl:apply-templates select="TaskServiceFolder"/>
	</xsl:template>
	
	<xsl:template match="NetJob">
		<xsl:text>          -----------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Name : </xsl:text>
		<xsl:value-of select="JobName" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Date : </xsl:text>
		<xsl:call-template name="PrintTime">
			<xsl:with-param name="dateTime" select="NextRun" />
		</xsl:call-template>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Account : </xsl:text>
		<xsl:value-of select="Account" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Application : </xsl:text>
		<xsl:value-of select="Application" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Parameters : </xsl:text>
		<xsl:value-of select="Parameters" />
		<xsl:call-template name="PrintReturn" />
		<xsl:for-each select="Triggers/Trigger">
			<xsl:text>Triggers : </xsl:text>
			<xsl:value-of select="." />
			<xsl:call-template name="PrintReturn" />
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="AtHeader">
		<xsl:text>Entries Read:      </xsl:text>
		<xsl:value-of select="@read" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Entries Available: </xsl:text>
		<xsl:value-of select="@total" />
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Status Flags: </xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>        E -> ERROR,       Last attempted execution failed</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>        P -> PERIODIC,    Program re-runs according to day/time info</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>        T -> TODAY,       Program scheduled to run today</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>        I -> INTERACTIVE, Program runs interactively</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:call-template name="PrintReturn" />
		<xsl:text>Status ID  Day                      Time     Command</xsl:text>
		<xsl:call-template name="PrintReturn" />
		<xsl:text>--------------------------------------------------------------------------</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="AtJob">
		<xsl:choose>
			<xsl:when test="Flags/JobExecError">
				<xsl:text>E</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="Flags/JobRunPeriodically">
				<xsl:text>P</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="Flags/JobRunsToday">
				<xsl:text>T</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> </xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="Flags/JobNonInteractive">
				<xsl:text> </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>I</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="5 - string-length(@id)" />
		</xsl:call-template>
		<xsl:value-of select="@id" />
		<xsl:text> </xsl:text>
		<xsl:choose>
			<xsl:when test="Flags/JobRunPeriodically">
				<xsl:text> Each </xsl:text>
				<xsl:call-template name="PrintDays">
					<xsl:with-param name="week" select="Weekday/@days" />
					<xsl:with-param name="month" select="Monthday/@days" />
					<xsl:with-param name="space" select="20" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="Flags/JobRunsToday">
				<xsl:text> Today                   </xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text> Next </xsl:text>
				<xsl:call-template name="PrintDays">
					<xsl:with-param name="week" select="Weekday/@days" />
					<xsl:with-param name="month" select="Monthday/@days" />
					<xsl:with-param name="space" select="20" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:text> </xsl:text>
		<xsl:variable name="hour" select="substring-before(substring-after(Time, 'T'), 'H')" />
		<xsl:variable name="minute" select="substring-before(substring-after(Time, 'H'), 'M')" />
		<xsl:value-of select="$hour" />
		<xsl:text>:</xsl:text>
		<xsl:value-of select="$minute" />

		<xsl:call-template name="Whitespace">
			<xsl:with-param name="i" select="5" />
		</xsl:call-template>
				
		<xsl:value-of select="CommandText" />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template match="TaskServiceFolder">
		<xsl:for-each select="Job">
			<xsl:if test="Flags/FlagEnabled">
				<xsl:text>------------------------------------------------------------------------</xsl:text>
				<xsl:call-template name="PrintReturn"/>

				<xsl:text>    Folder Path: </xsl:text>
				<xsl:value-of select="../@path"/>
				<xsl:call-template name="PrintReturn"/>

				<!--
				<xsl:text>    Folder Name: </xsl:text>
				<xsl:value-of select="../@name"/>
				<xsl:call-template name="PrintReturn"/>
				-->

				<xsl:text>       Job Name: </xsl:text>
				<xsl:value-of select="@name"/>
				<xsl:call-template name="PrintReturn"/>

				<!--
				<xsl:text>       Job Path: </xsl:text>
				<xsl:value-of select="@path"/>
				<xsl:call-template name="PrintReturn"/>
				-->

				<!--
				<xsl:text>        Enabled: </xsl:text>
				<xsl:choose>
					<xsl:when test="@enabled = 'true'">
						<xsl:text>YES</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>NO</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="PrintReturn"/>
				-->

				<xsl:text>          State: </xsl:text>
				<xsl:value-of select="@state"/>
				<xsl:call-template name="PrintReturn"/>

				<xsl:text>  Compatibility: </xsl:text>
				<xsl:value-of select="@compatibility"/>
				<xsl:call-template name="PrintReturn"/>

				<xsl:text>  Last Run Time: </xsl:text>
				<xsl:call-template name="PrintTime">
					<xsl:with-param name="dateTime" select="LastRunTime"/>
				</xsl:call-template>
				<xsl:call-template name="PrintReturn"/>
				<xsl:text>Last Run Status: </xsl:text>
				<xsl:value-of select="@lastRunResult"/>
				<xsl:call-template name="PrintReturn"/>

				<xsl:text>  Next Run Time: </xsl:text>
				<xsl:call-template name="PrintTime">
					<xsl:with-param name="dateTime" select="NextRunTime"/>
				</xsl:call-template>
				<xsl:call-template name="PrintReturn"/>

				<xsl:for-each select="Action">
					<xsl:text>Action: </xsl:text>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>        Type: </xsl:text>
					<xsl:value-of select="@type"/>
					<xsl:call-template name="PrintReturn"/>
					<xsl:if test="Exec">
						<xsl:text>        Path: </xsl:text>
						<xsl:value-of select="Exec/Path"/>
						<xsl:call-template name="PrintReturn"/>
						<xsl:text>        Args: </xsl:text>
						<xsl:value-of select="Exec/Arguments"/>
						<xsl:call-template name="PrintReturn"/>
						<xsl:if test="string-length(Exec/WorkingDir) &gt; 0">
							<xsl:text>         Dir: </xsl:text>
							<xsl:value-of select="Exec/WorkingDir"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
					</xsl:if>
					<xsl:if test="COM">
						<xsl:text>    Class Id: </xsl:text>
						<xsl:value-of select="COM/ClassId"/>
						<xsl:call-template name="PrintReturn"/>
						<xsl:text>        Data: </xsl:text>
						<xsl:value-of select="COM/Data"/>
						<xsl:call-template name="PrintReturn"/>
					</xsl:if>
				</xsl:for-each>
				
				<xsl:if test="Principal">
					<xsl:text>Principal: </xsl:text>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>         Type: </xsl:text>
					<xsl:value-of select="Principal/@logonType"/>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>    Run Level: </xsl:text>
					<xsl:value-of select="Principal/@runLevel"/>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>      User Id: </xsl:text>
					<xsl:value-of select="Principal/UserId"/>
					<xsl:call-template name="PrintReturn"/>
					<xsl:text>     Group Id: </xsl:text>
					<xsl:value-of select="Principal/GroupId"/>
					<xsl:call-template name="PrintReturn"/>
				</xsl:if>

				<xsl:for-each select="Trigger">
					<xsl:if test="@enabled = 'true'">
						<xsl:text>Trigger: </xsl:text>
						<xsl:call-template name="PrintReturn"/>

						<xsl:text>              Id: </xsl:text>
						<xsl:value-of select="Id"/>
						<xsl:call-template name="PrintReturn"/>

						<xsl:text>  Start Boundary: </xsl:text>
						<xsl:value-of select="StartBoundary"/>
						<xsl:call-template name="PrintReturn"/>

						<xsl:text>    End Boundary: </xsl:text>
						<xsl:value-of select="EndBoundary"/>
						<xsl:call-template name="PrintReturn"/>

						<xsl:text>      Time Limit: </xsl:text>
						<xsl:value-of select="ExecTimeLimit"/>
						<xsl:call-template name="PrintReturn"/>

						<xsl:text>            Type: </xsl:text>
						<xsl:value-of select="@type"/>
						<xsl:call-template name="PrintReturn"/>

						<xsl:if test="EventTrigger">
							<!--
							<xsl:text>    Subscription: </xsl:text>
							<xsl:value-of select="EventTrigger/Subscription"/>
							<xsl:call-template name="PrintReturn"/>
							-->
						</xsl:if>
						<xsl:if test="TimeTrigger">
							<xsl:text>    Random Delay: </xsl:text>
							<xsl:value-of select="TimeTrigger/RandomDelay"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
						<xsl:if test="DailyTrigger">
							<xsl:text>    Random Delay: </xsl:text>
							<xsl:value-of select="DailyTrigger/RandomDelay"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>   Days Interval: </xsl:text>
							<xsl:value-of select="DailyTrigger/DaysInterval"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
						<xsl:if test="WeeklyTrigger">
							<xsl:text>    Random Delay: </xsl:text>
							<xsl:value-of select="WeeklyTrigger/RandomDelay"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>    Days of Week: </xsl:text>
							<xsl:apply-templates select="WeeklyTrigger/DaysOfWeek"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
						<xsl:if test="MonthlyTrigger">
							<xsl:text>    Random Delay: </xsl:text>
							<xsl:value-of select="MonthlyTrigger/RandomDelay"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>   Days of Month: </xsl:text>
							<xsl:apply-templates select="MonthlyTrigger/DaysOfMonth"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>        Last Day: </xsl:text>
							<xsl:choose>
								<xsl:when test="MonthlyTrigger/@runOnLastDayOfMonth = 'true'">
									<xsl:text>YES</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>NO</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>  Months of Year: </xsl:text>
							<xsl:apply-templates select="MonthlyTrigger/MonthsOfYear"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
						<xsl:if test="MonthlyDOWTrigger">
							<xsl:text>    Random Delay: </xsl:text>
							<xsl:value-of select="MonthlyDOWTrigger/RandomDelay"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>   Days of Month: </xsl:text>
							<xsl:apply-templates select="MonthlyDOWTrigger/DaysOfWeek"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>       Last Week: </xsl:text>
							<xsl:choose>
								<xsl:when test="MonthlyDOWTrigger/@runOnLastWeekOfMonth = 'true'">
									<xsl:text>YES</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>NO</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>  Months of Year: </xsl:text>
							<xsl:apply-templates select="MonthlyDOWTrigger/MonthsOfYear"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>  Weeks of Month: </xsl:text>
							<xsl:apply-templates select="MonthlyDOWTrigger/WeeksOfMonth"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
						<xsl:if test="RegistrationTrigger">
							<xsl:text>           Delay: </xsl:text>
							<xsl:value-of select="RegistrationTrigger/Delay"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
						<xsl:if test="BootTrigger">
							<xsl:text>           Delay: </xsl:text>
							<xsl:value-of select="BootTrigger/Delay"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
						<xsl:if test="LogonTrigger">
							<xsl:text>           Delay: </xsl:text>
							<xsl:value-of select="LogonTrigger/Delay"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>         User Id: </xsl:text>
							<xsl:value-of select="LogonTrigger/UserId"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
						<xsl:if test="SessionStateChangeTrigger">
							<xsl:text>           Delay: </xsl:text>
							<xsl:value-of select="SessionStateChangeTrigger/Delay"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>         User Id: </xsl:text>
							<xsl:value-of select="SessionStateChangeTrigger/UserId"/>
							<xsl:call-template name="PrintReturn"/>
							<xsl:text>          Change: </xsl:text>
							<xsl:value-of select="SessionStateChangeTrigger/@change"/>
							<xsl:call-template name="PrintReturn"/>
						</xsl:if>
					</xsl:if>
				</xsl:for-each>
				<xsl:call-template name="PrintReturn"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="DaysOfMonth">
		<xsl:for-each select="Day">
			<xsl:value-of select="."/>
			<xsl:text> </xsl:text>
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="DaysOfWeek">
		<xsl:if test="Sunday">
			<xsl:text>SUN </xsl:text>
		</xsl:if>
		<xsl:if test="Monday">
			<xsl:text>MON </xsl:text>
		</xsl:if>
		<xsl:if test="Tuesday">
			<xsl:text>TUE </xsl:text>
		</xsl:if>
		<xsl:if test="Wednesday">
			<xsl:text>WED </xsl:text>
		</xsl:if>
		<xsl:if test="Thursday">
			<xsl:text>THU </xsl:text>
		</xsl:if>
		<xsl:if test="Friday">
			<xsl:text>FRI </xsl:text>
		</xsl:if>
		<xsl:if test="Saturday">
			<xsl:text>SAT</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="MonthsOfYear">
		<xsl:if test="January">
			<xsl:text>1 </xsl:text>
		</xsl:if>
		<xsl:if test="February">
			<xsl:text>2 </xsl:text>
		</xsl:if>
		<xsl:if test="March">
			<xsl:text>3 </xsl:text>
		</xsl:if>
		<xsl:if test="April">
			<xsl:text>4 </xsl:text>
		</xsl:if>
		<xsl:if test="May">
			<xsl:text>5 </xsl:text>
		</xsl:if>
		<xsl:if test="June">
			<xsl:text>6 </xsl:text>
		</xsl:if>
		<xsl:if test="July">
			<xsl:text>7 </xsl:text>
		</xsl:if>
		<xsl:if test="August">
			<xsl:text>8 </xsl:text>
		</xsl:if>
		<xsl:if test="September">
			<xsl:text>9 </xsl:text>
		</xsl:if>
		<xsl:if test="Octoboer">
			<xsl:text>10 </xsl:text>
		</xsl:if>
		<xsl:if test="November">
			<xsl:text>11 </xsl:text>
		</xsl:if>
		<xsl:if test="December">
			<xsl:text>12</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="WeeksOfMonth">
		<xsl:if test="First">
			<xsl:text>First </xsl:text>
		</xsl:if>
		<xsl:if test="Second">
			<xsl:text>Second </xsl:text>
		</xsl:if>
		<xsl:if test="Third">
			<xsl:text>Third </xsl:text>
		</xsl:if>
		<xsl:if test="Fourth">
			<xsl:text>Fourth </xsl:text>
		</xsl:if>
		<xsl:if test="Fifth">
			<xsl:text>Fifth </xsl:text>
		</xsl:if>
		<xsl:if test="Last">
			<xsl:text>Last </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="replace-string">
		<xsl:param name="text"/>
		<xsl:param name="from"/>
		<xsl:param name="to"/>
		<xsl:choose>
			<xsl:when test="contains($text, $from)">
			
			<xsl:variable name="before" select="substring-before($text, $from)"/>
			<xsl:variable name="after" select="substring-after($text, $from)"/>
			<xsl:variable name="prefix" select="concat($before, $to)"/>
			
			<xsl:value-of select="$before"/>
			<xsl:value-of select="$to"/>
			<xsl:call-template name="replace-string">
				<xsl:with-param name="text" select="$after"/>
				<xsl:with-param name="from" select="$from"/>
				<xsl:with-param name="to" select="$to"/>
			</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	<xsl:template name="PrintDays">
		<xsl:param name="week"  />
		<xsl:param name="month" />
		<xsl:param name="space" />
		<xsl:choose>
			<xsl:when test="$space &lt; 1"> <!--Do Nothing-->
			</xsl:when>
			
			<xsl:when test="$week">
				<xsl:variable name="printDay" select="substring-before($week, ' ')" />
				<xsl:variable name="nextDay" select="substring-after($week, ' ')" />
				<xsl:if test="string-length($printDay) &gt; 0">
					<xsl:value-of select="$printDay" />
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:call-template name="PrintDays">
					<xsl:with-param name="week" select="$nextDay" />
					<xsl:with-param name="month" select="$month" />
					<xsl:with-param name="space" select="$space - ( 1 + string-length( $printDay ) )" />
				</xsl:call-template>
			</xsl:when>
			
			<xsl:when test="$space &lt; 5 and ($month)">
				<xsl:text>.</xsl:text>
				<xsl:call-template name="PrintDays">
					<xsl:with-param name="week" select="$week" />
					<xsl:with-param name="month" select="$month" />
					<xsl:with-param name="space" select="$space - 1" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$month">
				<xsl:text> </xsl:text>
				<xsl:variable name="printDay" select="substring-before($month, ' ')" />
				<xsl:variable name="nextDay" select="substring-after($month, ' ')" />
				<xsl:value-of select="$printDay" />
				<xsl:call-template name="PrintDays">
					<xsl:with-param name="week" select="$week" />
					<xsl:with-param name="month" select="$nextDay" />
					<xsl:with-param name="space" select="$space - ( 1 + string-length( $printDay ) )" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="Whitespace">
					<xsl:with-param name="i" select="$space" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="NewJob">
		<xsl:text>New job added with id </xsl:text>
		<xsl:value-of select="@name" />
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	<xsl:template match="Deleted">
		<xsl:text>Job deleted</xsl:text>
		<xsl:call-template name="PrintReturn" />
	</xsl:template>
	
	<xsl:template name="PrintTime">
		<xsl:param name="dateTime" />

		<xsl:choose>
			<xsl:when test="$dateTime/@type = 'invalid'">
				<xsl:text>N/A</xsl:text>
			</xsl:when>
			<xsl:when test="string-length($dateTime) = 0">
				<xsl:text>N/A</xsl:text>
			</xsl:when>
			<xsl:otherwise>
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
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
</xsl:transform>