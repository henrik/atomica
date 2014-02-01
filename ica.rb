#!/usr/bin/env ruby
# encoding: utf-8
# AtomICA by Henrik Nyh <http://henrik.nyh.se>. See README.

require "ostruct"
require "json"
require "time"

require "rest_client"
require "builder"

class AtomICA
  NAME = "AtomICA"
  VERSION = "2.0"
  SCHEMA_DATE = "2014-02-01"

  # Sniffed from the iOS app. Required.
  # Expired? Borrow from https://github.com/liato/android-bankdroid/blob/master/src/com/liato/bankdroid/banking/banks/icabanken/ICABanken.java
  # or sniff with e.g. http://www.charlesproxy.com/
  API_KEY = "D65F6586-F0FA-477B-A2B2-05D9502C8E53"

  API_URL = "https://appserver.icabanken.se/login/"

  # Not required but a courtesy.
  USER_AGENT = "#{NAME}/#{VERSION} (https://github.com/henrik/atomica)"

  def initialize(pnr, pwd)
    @pnr = pnr.gsub(/\D/, '')  # Only keep digits.
    @pwd = pwd.gsub(/\D/, '')
  end

  def render
    atomize(scrape)
  end

  private

  def scrape
    items = []

    response = RestClient.get(API_URL, accept: :json, :ApiKey => API_KEY, :"User-Agent" => USER_AGENT, params: { customerId: @pnr, password: @pwd })
    hash = JSON.parse(response.body)
    hash.fetch("AccountList").fetch("Accounts").each do |account|
      account["Transactions"].each do |transaction|
        items << OpenStruct.new(
          account_name:   account["Name"],
          account_number: account["AccountNumber"],
          event:          transaction["MemoText"],
          time:           Time.parse(transaction["PostedDate"]),
          amount:         transaction["Amount"],
          balance:        transaction["AccountBalance"],
          is_debit:       transaction["Amount"] < 0,
        )
      end
    end

    items.sort_by(&:time)
  rescue RestClient::Forbidden
    [
      OpenStruct.new(
        account_name: "ERROR",
        account_number: "ERROR",
        event: "Wrong personnummer or PIN? Expired API key?",
        time: Time.now,
        amount: 0,
        balance: 0,
        is_debit: false
      )
    ]
  end  # def scrape

  def atomize(items)
    updated_at = (items.last ? items.last.time : Time.now).iso8601

    xml = Builder::XmlMarkup.new(indent: 2)
    xml.instruct! :xml, version: "1.0"
    xml.feed(xmlns: "http://www.w3.org/2005/Atom") do |feed|

      feed.title     "Kontohistorik för #{@pnr}"
      feed.id        "tag:ica-banken,#{SCHEMA_DATE}:#{@pnr}"
      feed.link      href: 'http://www.icabanken.se'
      feed.updated   updated_at
      feed.author    {|a| a.name 'ICA-banken' }
      feed.generator NAME, version: VERSION
      %w[personal banking finance].each {|cat| feed.category term: cat }

      items.each do |item|
        item_date = [%w[Sön Mån Tis Ons Tors Fre Lör][item.time.wday], item.time.strftime('%Y-%m-%d')].join(' ')
        style = item.is_debit ? 'color:red' : 'color:green'
        feed.entry do |entry|
          # Can't use time-with-index for id, since that will change
          entry.id      "tag:ica-banken,#{SCHEMA_DATE}:#{@pnr}/#{item.account_number};#{item.time.strftime('%Y-%m-%d')};#{item.event.gsub(/\W/, '')};#{item.amount};#{item.balance}".gsub(/\s+/, '')
          entry.title   item.event
          entry.content %{<table>
                            <tr><th>Konto:</th>  <td>#{item.account_name} (#{item.account_number})</td></tr>
                            <tr><th>Datum:</th>  <td>#{item_date}</td></tr>
                            <tr><th>Belopp:</th> <td style="#{style}">#{item.amount}</td></tr>
                            <tr><th>Saldo:</th>  <td>#{item.balance}</td></tr>
                          </table>}, type: 'html'
          entry.updated item.time.iso8601
        end
      end
    end.to_s
  end  # def atomize
end  # class AtomICA


if __FILE__ == $0
  # CLI
  pnr, pwd = ARGV
  puts AtomICA.new(pnr, pwd).render
end
