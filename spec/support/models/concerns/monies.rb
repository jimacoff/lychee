RSpec.shared_examples 'monies' do |factory, monies|
  subject { build factory }

  it { is_expected.to be_a_kind_of(Monies) }

  context 'currency' do
    context 'table structure' do
      it { is_expected.to have_db_column(:currency).of_type(:string) }
    end

    let(:new_currency) { Money::Currency.new('JPY') }
    let(:old_currency) { Money::Currency.new('AUD') }

    after do
      Site.current.currency = old_currency
      Site.current.save
    end

    def run
      Site.current.currency = new_currency
      Site.current.save
    end

    context 'owning site currency is changed' do
      it 'changes active site currency' do
        expect { run }.to change(Site.current, :currency).to eq(new_currency)
      end

      context 'existing instances' do
        it 'use database stored currency' do
          expect { run }.not_to change(subject, :currency)
        end
      end

      context 'new instances' do
        it 'use the new site currency' do
          run
          new_instance = build(factory)
          expect(new_instance.currency).to eq(Site.current.currency)
        end
      end
    end
  end

  monies.each do |money_record|
    money = money_record[:field]
    calculated = money_record[:calculated]

    context 'table structure' do
      it { is_expected.to have_db_column("#{money}_cents").of_type(:integer) }
    end

    context "#{money}" do
      describe "##{money}=" do
        if calculated
          it 'is not callable' do
            expect { subject.send("#{money}=", 1) }.to raise_error
          end
        else
          context 'specifying cents' do
            let(:new_value) { Faker::Number.number(3).to_i + 1 }
            it "modifies the underlying #{money}_cents field" do
              expect { subject.send("#{money}=", new_value) }
                .to change(subject, "#{money}_cents").to eq(new_value)
            end
          end
          context 'specifying dollars and cents' do
            let(:new_value) { Faker::Number.numerify('1##.##').to_d }
            it "modifies the underlying #{money}_cents field" do
              expect { subject.send("#{money}=", new_value) }
                .to change(subject, "#{money}_cents").to eq(new_value * 100)
            end
          end
        end
      end

      describe "##{money}_cents=" do
        it 'is not callable' do
          expect { subject.send("#{money}_cents=", 1) }.to raise_error
        end
      end

      describe "##{money}" do
        it 'returns dollars as Money' do
          expect(subject.send(money)).to be_a Money
        end
        # Ensure any future library change doesn't bite us as this got
        # modified between 5.y and 6.y
        it 'returns dollars as BigDecimal' do
          expect(subject.send(money).dollars).to be_a BigDecimal
        end
        it 'returns amount as BigDecimal' do
          expect(subject.send(money).dollars).to be_a BigDecimal
        end
      end
    end
  end
end
